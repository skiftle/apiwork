# frozen_string_literal: true

module Apiwork
  module Schema
    class Base
      include Abstractable
      include Serialization

      class_attribute :attribute_definitions, default: {}
      class_attribute :association_definitions, default: {}
      class_attribute :discriminator_column, default: nil
      class_attribute :discriminator_name, default: nil
      class_attribute :variant_tag, default: nil
      class_attribute :variants, default: {}
      class_attribute :_root, default: nil
      class_attribute :_adapter_config, default: {}
      class_attribute :_sti_type, default: nil
      class_attribute :_description, default: nil
      class_attribute :_deprecated, default: false
      class_attribute :_example, default: nil

      # @api private
      attr_reader :context,
                  :include,
                  :object

      def initialize(object, context: {}, include: nil)
        @object = object
        @context = context
        @include = include
      end

      class << self
        # @api private
        attr_accessor :_model_class

        # @api private
        attr_writer :_auto_detection_complete,
                    :type

        def _auto_detection_complete
          @_auto_detection_complete || false
        end

        # Sets or gets the model class for this schema.
        #
        # By default, the model is auto-detected from the schema name
        # (e.g., InvoiceSchema → Invoice). Use this to override.
        #
        # @param value [Class] the ActiveRecord model class (optional)
        # @return [Class, nil] the model class
        # @raise [ArgumentError] if value is not a Class
        #
        # @example Explicit model
        #   class InvoiceSchema < Apiwork::Schema::Base
        #     model Invoice
        #   end
        #
        # @example Namespaced model
        #   class InvoiceSchema < Apiwork::Schema::Base
        #     model Billing::Invoice
        #   end
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

        # @api private
        def model_class
          ensure_auto_detection_complete
          _model_class
        end

        # Declares the JSON root key for this schema.
        #
        # Adapters can use this to wrap responses in a root key.
        #
        # @param singular [String, Symbol] root key for single records
        # @param plural [String, Symbol] root key for collections (default: singular.pluralize)
        #
        # @example Custom root key
        #   class InvoiceSchema < Apiwork::Schema::Base
        #     root :bill, :bills
        #   end
        def root(singular, plural = nil)
          singular = singular.to_s
          plural = plural ? plural.to_s : singular.pluralize
          self._root = { singular:, plural: }
        end

        # @api private
        def api_class
          return nil unless name

          namespace_parts = name.deconstantize.split('::')
          return nil if namespace_parts.empty?

          Apiwork::API.find("/#{namespace_parts.map(&:underscore).join('/')}")
        end

        # Configures adapter options for this schema.
        #
        # Use this to override API-level adapter settings for a specific
        # resource. Available options depend on the adapter being used.
        #
        # @yield block for adapter configuration
        #
        # @example Custom pagination for this resource
        #   class ActivitySchema < Apiwork::Schema::Base
        #     adapter do
        #       pagination do
        #         strategy :cursor
        #         default_size 50
        #       end
        #     end
        #   end
        def adapter(&block)
          return unless block

          self._adapter_config = _adapter_config.dup
          api_adapter_class = api_class&.adapter&.class || Adapter::Apiwork
          builder = Configuration::Builder.new(api_adapter_class, _adapter_config)
          builder.instance_eval(&block)
        end

        # @api private
        def resolve_option(name, subkey = nil)
          adapter_class = api_class&.adapter&.class || Adapter::Apiwork
          opt = adapter_class.options[name]
          return nil unless opt

          if opt.nested? && subkey
            value = _adapter_config.dig(name, subkey)
            value = api_class&.adapter_config&.dig(name, subkey) if value.nil?
            value.nil? ? opt.children[subkey]&.default : value
          else
            value = _adapter_config[name]
            value = api_class&.adapter_config&.[](name) if value.nil?
            value.nil? ? opt.resolved_default : value
          end
        end

        # Defines an attribute for serialization and API contracts.
        #
        # Types and nullability are auto-detected from the model's database
        # columns when available.
        #
        # @param name [Symbol] attribute name (must match model attribute)
        # @option options [Symbol] :type data type (:string, :integer, :boolean,
        #   :datetime, :date, :uuid, :decimal, :float, :object, :array)
        # @option options [Array] :enum allowed values
        # @option options [Boolean] :optional field can be omitted in responses
        # @option options [Boolean] :nullable field can be null
        # @option options [Boolean] :filterable enable filtering on this field
        # @option options [Boolean] :sortable enable sorting on this field
        # @option options [Boolean, Hash] :writable allow in create/update payloads.
        #   Use {on: [:create]} to limit to specific actions
        # @option options [Proc] :encode transform value during serialization
        # @option options [Proc] :decode transform value during deserialization
        # @option options [Symbol] :empty how to handle empty strings (:null, :keep)
        # @option options [Integer] :min minimum value (numeric) or length (string)
        # @option options [Integer] :max maximum value (numeric) or length (string)
        # @option options [String] :description documentation description
        # @option options [Object] :example example value for docs
        # @option options [Symbol] :format format hint (:email, :uri, :uuid, etc.)
        # @option options [Boolean] :deprecated mark as deprecated
        #
        # @example Basic attribute
        #   attribute :title
        #   attribute :price, type: :decimal, min: 0
        #
        # @example With filtering and sorting
        #   attribute :status, filterable: true, sortable: true
        #
        # @example Writable only on create
        #   attribute :email, writable: { on: [:create] }
        def attribute(name, **options)
          self.attribute_definitions = attribute_definitions.merge(
            name => AttributeDefinition.new(name, self, **options)
          )
        end

        # Defines a has_one association for serialization and contracts.
        #
        # The association is auto-detected from the model. Use options to
        # control serialization behavior, nested attributes, and querying.
        #
        # @param name [Symbol] association name (must match model association)
        # @option options [Class] :schema explicit schema class for the association
        # @option options [Array, Hash] :polymorphic enable polymorphic association
        #   with allowed types (Array) or explicit mappings (Hash)
        # @option options [Symbol] :include :always or :optional (default: :optional)
        # @option options [Boolean, Hash] :writable enable nested attributes
        #   (true, false, or { on: [:create, :update] })
        # @option options [Boolean] :filterable enable filtering on this association
        # @option options [Boolean] :sortable enable sorting on this association
        # @option options [Boolean] :nullable whether null is allowed (auto-detect from DB)
        # @option options [String] :description documentation description
        # @option options [Object] :example example value for docs
        # @option options [Boolean] :deprecated mark as deprecated
        #
        # @example Basic association
        #   has_one :profile
        #
        # @example With explicit schema
        #   has_one :author, schema: UserSchema
        #
        # @example Nested attributes
        #   has_one :address, writable: true
        #
        # @example Polymorphic
        #   has_one :imageable, polymorphic: [:product, :user]
        def has_one(name, **options)
          self.association_definitions = association_definitions.merge(
            name => AssociationDefinition.new(name, :has_one, self, **options)
          )
        end

        # Defines a has_many association for serialization and contracts.
        #
        # See {#has_one} for shared options. Additionally supports:
        #
        # @param name [Symbol] association name (must match model association)
        # @option options [Boolean] :allow_destroy allow destroying nested records
        #   (requires accepts_nested_attributes_for with allow_destroy: true)
        # @option options (see #has_one)
        #
        # @example Basic collection
        #   has_many :line_items
        #
        # @example With nested attributes and destroy
        #   has_many :line_items, writable: true, allow_destroy: true
        #
        # @example Always include
        #   has_many :tags, include: :always
        def has_many(name, **options)
          self.association_definitions = association_definitions.merge(
            name => AssociationDefinition.new(name, :has_many, self, **options)
          )
        end

        # Defines a belongs_to association for serialization and contracts.
        #
        # Nullability is auto-detected from the foreign key column.
        # See {#has_one} for all available options.
        #
        # @param name [Symbol] association name (must match model association)
        # @option options (see #has_one)
        #
        # @example Basic belongs_to
        #   belongs_to :customer
        #
        # @example Filterable
        #   belongs_to :category, filterable: true
        def belongs_to(name, **options)
          self.association_definitions = association_definitions.merge(
            name => AssociationDefinition.new(name, :belongs_to, self, **options)
          )
        end

        # Enables STI (Single Table Inheritance) polymorphism for this schema.
        #
        # Call on the base schema to enable discriminated responses. Variant
        # schemas must call `variant` to register themselves.
        #
        # @param name [Symbol] discriminator field name in API responses
        #   (defaults to Rails inheritance_column, usually :type)
        # @return [self]
        #
        # @example Base schema with STI
        #   class VehicleSchema < Apiwork::Schema::Base
        #     discriminator :vehicle_type
        #     attribute :name
        #   end
        #
        #   class CarSchema < VehicleSchema
        #     variant as: :car
        #     attribute :doors
        #   end
        def discriminator(name = nil)
          ensure_auto_detection_complete
          column = model_class.inheritance_column.to_sym
          self.discriminator_column = column
          self.discriminator_name = name || column
          self
        end

        # Registers this schema as an STI variant of its parent.
        #
        # The parent schema must have called `discriminator` first.
        # Responses will use the variant's attributes based on the
        # record's actual type.
        #
        # @param as [Symbol] discriminator value in API responses
        #   (defaults to model's sti_name)
        # @return [self]
        #
        # @example
        #   class CarSchema < VehicleSchema
        #     variant as: :car
        #     attribute :doors
        #   end
        def variant(as: nil)
          ensure_auto_detection_complete
          tag = as || model_class.sti_name

          self.variant_tag = tag.to_sym
          self._sti_type = model_class.sti_name

          superclass.register_variant(tag: variant_tag, schema: self, sti_type: _sti_type) if superclass.respond_to?(:register_variant)

          self
        end

        # @api private
        def register_variant(tag:, schema:, sti_type:)
          self.variants = variants.merge(tag => { schema: schema, sti_type: sti_type })
          self._abstract = true
        end

        # @api private
        def sti_base?
          return false if sti_variant?

          discriminator_column.present? && variants.any?
        end

        # @api private
        def sti_variant?
          variant_tag.present?
        end

        # @api private
        def needs_discriminator_transform?
          variants.any? { |tag, data| tag.to_s != data[:sti_type] }
        end

        # @api private
        def discriminator_sti_mapping
          variants.transform_values { |data| data[:sti_type] }
        end

        # Sets or gets a description for this schema.
        #
        # Used in generated documentation (OpenAPI, etc.) to describe
        # what this resource represents.
        #
        # @param value [String] description text (optional)
        # @return [String, nil] the description
        #
        # @example
        #   class InvoiceSchema < Apiwork::Schema::Base
        #     description 'Represents a customer invoice'
        #   end
        def description(value = nil)
          return _description if value.nil?

          self._description = value
        end

        # Marks this schema as deprecated.
        #
        # Deprecated schemas are included in generated documentation
        # with a deprecation notice.
        #
        # @param value [Boolean] whether deprecated (default: true)
        #
        # @example
        #   class LegacyOrderSchema < Apiwork::Schema::Base
        #     deprecated
        #   end
        def deprecated(value = true)
          self._deprecated = value
        end

        # @api private
        def deprecated?
          _deprecated
        end

        # Sets or gets an example value for this schema.
        #
        # Used in generated documentation to show example responses.
        #
        # @param value [Hash] example data (optional)
        # @return [Hash, nil] the example
        #
        # @example
        #   class InvoiceSchema < Apiwork::Schema::Base
        #     example { id: 1, total: 99.00, status: 'paid' }
        #   end
        def example(value = nil)
          return _example if value.nil?

          self._example = value
        end

        # @api private
        def type
          @type || model_class&.model_name&.element
        end

        # @api private
        def root_key
          if _root
            RootKey.new(_root[:singular], _root[:plural])
          else
            type_name = type || model_class&.model_name&.element
            RootKey.new(type_name)
          end
        end

        private

        def ensure_auto_detection_complete
          return if _auto_detection_complete

          self._auto_detection_complete = true

          return if _model_class.present?
          return if abstract?

          schema_name = name.demodulize
          model_name = schema_name.sub(/Schema$/, '')
          return if model_name.blank?

          namespace = name.deconstantize
          detected = if namespace.present?
                       "#{namespace}::#{model_name}".safe_constantize || model_name.safe_constantize
                     else
                       model_name.safe_constantize
                     end

          if detected.present?
            self._model_class = detected
          else
            raise ConfigurationError.new(
              code: :model_not_found,
              detail: "Could not find model '#{model_name}' for #{name}. " \
                      "Either create the model, declare it explicitly with 'model YourModel', " \
                      "or mark this schema as abstract with 'abstract!'",
              path: []
            )
          end
        end
      end
    end
  end
end
