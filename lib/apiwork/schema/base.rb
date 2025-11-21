# frozen_string_literal: true

module Apiwork
  module Schema
    class Base
      include Abstractable
      include Serialization

      class_attribute :_model_class
      class_attribute :attribute_definitions, default: {}
      class_attribute :association_definitions, default: {}
      class_attribute :_output_key_format, default: nil
      class_attribute :_input_key_format, default: nil
      class_attribute :_root, default: nil
      class_attribute :_auto_detection_complete, default: false
      class_attribute :_configuration, default: {}
      class_attribute :_discriminator_column, default: nil
      class_attribute :_discriminator_name, default: nil
      class_attribute :_variant_tag, default: nil
      class_attribute :_sti_type, default: nil
      class_attribute :_variants, default: {}

      attr_reader :object, :context, :includes

      def initialize(object, context: {}, includes: nil)
        @object = object
        @context = context
        @includes = includes
      end

      def detect_association_resource(association_name)
        return nil unless self.class.respond_to?(:model_class)
        return nil unless self.class.model_class

        reflection = object.class.reflect_on_association(association_name)
        return nil unless reflection

        Apiwork::Schema::Resolver.from_association(reflection, self.class)
      end

      class << self
        def contract
          Contract::SchemaRegistry.find(self)
        end

        def model(value = nil)
          if value
            unless value.is_a?(Class)
              raise ArgumentError, "model must be a Class constant, got #{value.class}. " \
                                   "Use: model Post (not 'Post' or :post)"
            end
            self._model_class = value
            value
          else
            _model_class
          end
        end

        def auto_detect_model
          return if _model_class.present?
          return if abstract?

          schema_name = name.demodulize
          model_name = schema_name.sub(/Schema$/, '')
          return if model_name.blank?

          model_class = try_constantize_model(name.deconstantize, model_name)

          if model_class.present?
            self._model_class = model_class
          else
            raise_model_not_found_error(model_name)
          end
        end

        def raise_model_not_found_error(model_name)
          error = ConfigurationError.new(
            code: :model_not_found,
            detail: "Could not find model '#{model_name}' for #{name}. " \
                    "Either create the model, declare it explicitly with 'model YourModel', " \
                    "or mark this schema as abstract with 'abstract'",
            path: []
          )

          raise error
        end

        def try_constantize_model(namespace, model_name)
          if namespace.present?
            full_name = "#{namespace}::#{model_name}"
            begin
              return full_name.constantize
            rescue NameError
              # continue to try without namespace
            end
          end

          model_name.constantize
        rescue NameError
          nil
        end

        def model_class
          ensure_auto_detection_complete
          _model_class
        end

        def model?
          ensure_auto_detection_complete
          _model_class.present?
        end

        def ensure_auto_detection_complete
          return if _auto_detection_complete

          self._auto_detection_complete = true
          auto_detect_model
        end

        def root(singular, plural = nil)
          singular_str = singular.to_s
          plural_str = plural ? plural.to_s : singular_str.pluralize
          self._root = { singular: singular_str, plural: plural_str }
        end

        # Resolve API class from schema namespace
        # Example: Api::V1::PostSchema → /api/v1
        def api_class
          path = api_path
          return nil unless path

          Apiwork::API.find(path)
        end

        # Derive API path from schema class namespace
        # Example: Api::V1::PostSchema → /api/v1
        def api_path
          return nil unless name

          namespace_parts = name.deconstantize.split('::')
          return nil if namespace_parts.empty?

          "/#{namespace_parts.map(&:underscore).join('/')}"
        end

        def output_key_format
          Configuration::Resolver.resolve(:output_key_format, schema_class: self)
        end

        def input_key_format
          Configuration::Resolver.resolve(:input_key_format, schema_class: self)
        end

        def output_key_format=(value)
          self._output_key_format = value
        end

        def input_key_format=(value)
          self._input_key_format = value
        end

        # Configure schema-level settings
        #
        # @example
        #   configure do
        #     default_page_size 50
        #     max_page_size 200
        #   end
        def configure(&block)
          return unless block

          builder = Configuration::Builder.new(_configuration)
          builder.instance_eval(&block)
        end

        # Access configuration hash
        # @return [Hash] Schema configuration settings
        def configuration
          _configuration
        end

        def attribute(name, **options)
          self.attribute_definitions = attribute_definitions.merge(
            name => AttributeDefinition.new(name, schema_class: self, **options)
          )
        end

        def has_one(name, **options)
          self.association_definitions = association_definitions.merge(
            name => AssociationDefinition.new(name, type: :has_one, schema_class: self, **options)
          )
        end

        def has_many(name, **options)
          self.association_definitions = association_definitions.merge(
            name => AssociationDefinition.new(name, type: :has_many, schema_class: self, **options)
          )
        end

        def belongs_to(name, **options)
          self.association_definitions = association_definitions.merge(
            name => AssociationDefinition.new(name, type: :belongs_to, schema_class: self, **options)
          )
        end

        # Declare STI base schema with optional custom API field name
        # @param as [Symbol, nil] Optional custom API field name (defaults to Rails column name)
        # @example
        #   discriminator           # Uses Rails inheritance_column as-is
        #   discriminator as: :kind # Maps Rails 'type' column to API 'kind' field
        def discriminator(as: nil)
          ensure_auto_detection_complete
          column = model_class.inheritance_column.to_sym
          self._discriminator_column = column
          self._discriminator_name = as || column
          self
        end

        # Declare STI variant schema
        # @param as [String, Symbol, nil] API discriminator value (defaults to Rails sti_name)
        # @example
        #   variant                # Uses Rails sti_name as API tag (e.g., "PersonClient")
        #   variant as: "person"   # Custom API tag
        def variant(as: nil)
          ensure_auto_detection_complete
          variant_tag = as || model_class.sti_name

          self._variant_tag = variant_tag.to_sym
          self._sti_type = model_class.sti_name

          # Register with parent schema
          superclass.register_variant(tag: _variant_tag, schema: self, sti_type: _sti_type) if superclass.respond_to?(:register_variant)

          self
        end

        # Internal: Register variant from child schema
        def register_variant(tag:, schema:, sti_type:)
          self._variants = _variants.merge(tag => { schema: schema, sti_type: sti_type })
          self.abstract_class = true # Auto-mark as abstract
        end

        # Accessors for STI metadata
        def discriminator_column
          _discriminator_column
        end

        def discriminator_name
          _discriminator_name
        end

        def variant_tag
          _variant_tag
        end

        def sti_type
          _sti_type
        end

        def variants
          _variants
        end

        # Check if this is an STI base schema
        # A schema is a base if it has discriminator and variants, but is not itself a variant
        def sti_base?
          return false if sti_variant?

          _discriminator_column.present? && _variants.any?
        end

        # Check if this is an STI variant schema
        def sti_variant?
          _variant_tag.present?
        end

        attr_writer :type, :default_sort, :default_page_size, :max_page_size

        def type
          @type || model_class&.model_name&.element
        end

        def default_sort
          Configuration::Resolver.resolve(:default_sort, schema_class: self)
        end

        def default_page_size
          Configuration::Resolver.resolve(:default_page_size, schema_class: self)
        end

        def max_page_size
          Configuration::Resolver.resolve(:max_page_size, schema_class: self)
        end

        # Validate all attribute definitions (call explicitly in tests after database setup)
        def validate!
          attribute_definitions.each_value(&:validate!)
        end

        def root_key
          if _root
            RootKey.new(_root[:singular], _root[:plural])
          else
            type_name = type || model_class&.model_name&.element
            RootKey.new(type_name)
          end
        end

        def filterable_attributes
          @filterable_attributes ||= attributes_with_option(:filterable)
        end

        def sortable_attributes
          @sortable_attributes ||= attributes_with_option(:sortable)
        end

        def writable_attributes_for(action)
          @writable_attributes_cache ||= {}
          @writable_attributes_cache[action] ||= begin
            writable = attribute_definitions.select do |_, definition|
              definition.writable_for?(action)
            end
            writable.keys.freeze
          end
        end

        def required_attributes_for(action)
          @required_attributes_cache ||= {}
          @required_attributes_cache[action] ||= begin
            return [].freeze if model_class.nil?

            writable_attrs = writable_attributes_for(action)
            (required_columns & writable_attrs).freeze
          end
        end

        def column_for(attribute_name)
          model_class&.columns_hash&.[](attribute_name.to_s)
        end

        def required_columns
          return [] unless model_class

          model_class.columns
                     .reject(&:null)
                     .select { |col| col.default.nil? }
                     .map(&:name)
                     .map(&:to_sym)
        end

        def column_nullable?(attribute_name)
          column_for(attribute_name)&.null || false
        end

        def column_type_for(attribute_name)
          model_class&.type_for_attribute(attribute_name.to_s)&.type
        end

        private

        def attributes_with_option(option)
          selected = attribute_definitions.select do |_, definition|
            value = definition.public_send("#{option}?")
            value.is_a?(TrueClass) || (value.is_a?(Proc) && value)
          end
          selected.keys.freeze
        end
      end
    end
  end
end
