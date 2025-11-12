# frozen_string_literal: true

module Apiwork
  module Schema
    class Base
      include Concerns::AbstractClass
      include Serialization

      class_attribute :_model_class
      class_attribute :attribute_definitions, default: {}
      class_attribute :association_definitions, default: {}
      class_attribute :_serialize_key_transform, default: nil
      class_attribute :_deserialize_key_transform, default: nil
      class_attribute :_auto_include_associations, default: nil
      class_attribute :_validated_includes, default: nil
      class_attribute :_root, default: nil
      class_attribute :_auto_detection_complete, default: false

      attr_reader :object, :context, :includes

      def initialize(object, context: {}, includes: nil)
        @object = object
        @context = context
        @includes = includes
      end

      def detect_association_resource(association_name)
        return nil unless self.class.respond_to?(:model_class) && self.class.model_class

        reflection = object.class.reflect_on_association(association_name)
        return nil unless reflection

        Apiwork::Schema::Resolver.from_association(reflection, self.class)
      end

      class << self
        # Returns contract class for this schema (explicit or generated)
        # Uses SchemaContractRegistry to cache and manage contracts
        # @return [Class] Contract class
        def contract
          Contract::SchemaContractRegistry.contract_for_schema(self)
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
          return if abstract_class? || name.nil?

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
                    "or mark this schema as abstract with 'self.abstract_class = true'",
            path: []
          )

          Errors::Handler.handle(error, context: {
                                   schema: name,
                                   expected_model: model_name
                                 })
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

        def serialize_key_transform
          _serialize_key_transform || Apiwork.configuration.serialize_key_transform
        end

        def deserialize_key_transform
          _deserialize_key_transform || Apiwork.configuration.deserialize_key_transform
        end

        def serialize_key_transform=(value)
          self._serialize_key_transform = value
        end

        def deserialize_key_transform=(value)
          self._deserialize_key_transform = value
        end

        def auto_include_associations
          _auto_include_associations.nil? ? Apiwork.configuration.auto_include_associations : _auto_include_associations
        end

        def auto_include_associations=(value)
          self._auto_include_associations = value
        end

        def attribute(name, **options)
          self.attribute_definitions = attribute_definitions.merge(
            name => AttributeDefinition.new(name, klass: self, **options)
          )
        end

        def has_one(name, **options) # rubocop:disable Naming/PredicatePrefix
          self.association_definitions = association_definitions.merge(
            name => AssociationDefinition.new(name, type: :has_one, klass: self, **options)
          )
        end

        def has_many(name, **options) # rubocop:disable Naming/PredicatePrefix
          self.association_definitions = association_definitions.merge(
            name => AssociationDefinition.new(name, type: :has_many, klass: self, **options)
          )
        end

        def belongs_to(name, **options)
          self.association_definitions = association_definitions.merge(
            name => AssociationDefinition.new(name, type: :belongs_to, klass: self, **options)
          )
        end

        attr_writer :type, :default_sort, :default_page_size, :maximum_page_size

        def type
          @type || model_class&.model_name&.element
        end

        def default_sort
          @default_sort || Apiwork.configuration.default_sort
        end

        def default_page_size
          @default_page_size || Apiwork.configuration.default_page_size
        end

        def maximum_page_size
          @maximum_page_size || Apiwork.configuration.maximum_page_size
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
          @writable_attributes_cache[action] ||= attribute_definitions
                                                 .select do |_, definition|
            definition.writable_for?(action)
          end
                                                 .keys
                                                 .freeze
        end

        def required_attributes_for(action)
          @required_attributes_cache ||= {}
          @required_attributes_cache[action] ||= begin
            return [].freeze if model_class.nil?

            writable_attrs = writable_attributes_for(action)
            (required_columns & writable_attrs).freeze
          end
        end

        # Model introspection helpers
        # Get column metadata for an attribute
        #
        # @param attribute_name [Symbol, String] Attribute name
        # @return [ActiveRecord::ConnectionAdapters::Column, nil] Column object or nil
        def column_for(attribute_name)
          model_class&.columns_hash&.[](attribute_name.to_s)
        end

        # Get list of required column names (non-null with no default)
        #
        # @return [Array<Symbol>] Array of required column names
        def required_columns
          return [] unless model_class

          model_class.columns
                     .reject(&:null)
                     .select { |col| col.default.nil? }
                     .map(&:name)
                     .map(&:to_sym)
        end

        # Check if a column is nullable
        #
        # @param attribute_name [Symbol, String] Attribute name
        # @return [Boolean] True if column allows null values
        def column_nullable?(attribute_name)
          column_for(attribute_name)&.null || false
        end

        # Get column type for an attribute
        #
        # @param attribute_name [Symbol, String] Attribute name
        # @return [Symbol, nil] Column type (:string, :integer, etc.) or nil
        def column_type_for(attribute_name)
          model_class&.type_for_attribute(attribute_name.to_s)&.type
        end

        private

        def attributes_with_option(option)
          attribute_definitions
            .select do |_, definition|
              value = definition.public_send("#{option}?")
              value.is_a?(TrueClass) || (value.is_a?(Proc) && value)
            end
            .keys
            .freeze
        end

        def name_of_self
          respond_to?(:name) ? name : to_s
        end
      end
    end
  end
end
