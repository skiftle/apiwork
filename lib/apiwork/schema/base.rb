# frozen_string_literal: true

module Apiwork
  module Schema
    # @api public
    # Base class for resource schemas.
    #
    # Schemas define attributes and associations for serialization.
    # Types and nullability are auto-detected from the model's database columns.
    #
    # @example Basic schema
    #   class InvoiceSchema < Apiwork::Schema::Base
    #     attribute :id
    #     attribute :title
    #     attribute :amount, type: :decimal
    #     attribute :status, filterable: true, sortable: true
    #
    #     belongs_to :customer
    #     has_many :line_items
    #   end
    #
    # @!scope class
    # @!method abstract!
    #   @api public
    #   Marks this schema as abstract.
    #
    #   Abstract schemas don't require a model and serve as base classes
    #   for other schemas. Use this when creating application-wide base schemas.
    #   Subclasses automatically become non-abstract.
    #   @return [void]
    #   @example Application base schema
    #     class ApplicationSchema < Apiwork::Schema::Base
    #       abstract!
    #     end
    #
    # @!method abstract?
    #   @api public
    #   Returns whether this schema is abstract.
    #   @return [Boolean] true if abstract
    class Base
      include Abstractable

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

      attr_reader :context,
                  :include,
                  :object

      class << self
        attr_writer :type

        # @api public
        # Sets or gets the model class for this schema.
        #
        # By default, the model is auto-detected from the schema name
        # (e.g., InvoiceSchema becomes Invoice). Use this to override.
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
              raise ArgumentError,
                    "model must be a Class constant, got #{value.class}. " \
                                                       "Use: model Post (not 'Post' or :post)"
            end
            @model_class = value
            value
          else
            @model_class
          end
        end

        # @api public
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
        def root(singular, plural = singular.to_s.pluralize)
          self._root = { plural: plural.to_s, singular: singular.to_s }
        end

        # @api public
        # Configures adapter options for this schema.
        #
        # Use this to override API-level adapter settings for a specific
        # resource. Available options depend on the adapter being used.
        #
        # @yield block for adapter configuration
        # @see Adapter::Base
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
          builder = Configuration::Builder.new(api_class.adapter.class, _adapter_config)
          builder.instance_eval(&block)
        end

        # @api public
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
        def attribute(
          name,
          decode: nil,
          deprecated: false,
          description: nil,
          empty: nil,
          encode: nil,
          enum: nil,
          example: nil,
          filterable: nil,
          format: nil,
          max: nil,
          min: nil,
          nullable: nil,
          of: nil,
          optional: nil,
          sortable: nil,
          type: nil,
          writable: nil,
          &block
        )
          self.attribute_definitions = attribute_definitions.merge(
            name => AttributeDefinition.new(
              name,
              self,
              decode:,
              deprecated:,
              description:,
              empty:,
              encode:,
              enum:,
              example:,
              filterable:,
              format:,
              max:,
              min:,
              nullable:,
              of:,
              optional:,
              sortable:,
              type:,
              writable:,
              &block
            ),
          )
        end

        # @api public
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
        def has_one(
          name,
          class_name: nil,
          deprecated: false,
          description: nil,
          example: nil,
          filterable: false,
          include: :optional,
          nullable: nil,
          optional: nil,
          polymorphic: nil,
          schema: nil,
          sortable: false,
          writable: false
        )
          self.association_definitions = association_definitions.merge(
            name => AssociationDefinition.new(
              name,
              :has_one,
              self,
              class_name:,
              deprecated:,
              description:,
              example:,
              filterable:,
              include:,
              nullable:,
              optional:,
              polymorphic:,
              schema:,
              sortable:,
              writable:,
            ),
          )
        end

        # @api public
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
        def has_many(
          name,
          allow_destroy: false,
          class_name: nil,
          deprecated: false,
          description: nil,
          example: nil,
          filterable: false,
          include: :optional,
          nullable: nil,
          optional: nil,
          polymorphic: nil,
          schema: nil,
          sortable: false,
          writable: false
        )
          self.association_definitions = association_definitions.merge(
            name => AssociationDefinition.new(
              name,
              :has_many,
              self,
              allow_destroy:,
              class_name:,
              deprecated:,
              description:,
              example:,
              filterable:,
              include:,
              nullable:,
              optional:,
              polymorphic:,
              schema:,
              sortable:,
              writable:,
            ),
          )
        end

        # @api public
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
        def belongs_to(
          name,
          class_name: nil,
          deprecated: false,
          description: nil,
          example: nil,
          filterable: false,
          include: :optional,
          nullable: nil,
          optional: nil,
          polymorphic: nil,
          schema: nil,
          sortable: false,
          writable: false
        )
          self.association_definitions = association_definitions.merge(
            name => AssociationDefinition.new(
              name,
              :belongs_to,
              self,
              class_name:,
              deprecated:,
              description:,
              example:,
              filterable:,
              include:,
              nullable:,
              optional:,
              polymorphic:,
              schema:,
              sortable:,
              writable:,
            ),
          )
        end

        # @api public
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

        # @api public
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

          superclass.register_variant(schema: self, sti_type: _sti_type, tag: variant_tag)

          self
        end

        # @api public
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

        # @api public
        # Marks this schema as deprecated.
        #
        # Deprecated schemas are included in generated documentation
        # with a deprecation notice.
        #
        # @example
        #   class LegacyOrderSchema < Apiwork::Schema::Base
        #     deprecated
        #   end
        def deprecated
          self._deprecated = true
        end

        # @api public
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

        # @api public
        # Serializes a record or collection using this schema.
        #
        # Converts ActiveRecord objects to JSON-ready hashes based on
        # attribute and association definitions.
        #
        # @param object_or_collection [Object, Array] record(s) to serialize
        # @param context [Hash] context data available during serialization
        # @param include [Symbol, Array, Hash] associations to include
        # @return [Hash, Array<Hash>] serialized data
        #
        # @example Serialize a single record
        #   InvoiceSchema.serialize(invoice)
        #
        # @example Serialize with associations
        #   InvoiceSchema.serialize(invoice, include: [:customer, :line_items])
        #
        # @example Serialize a collection
        #   InvoiceSchema.serialize(Invoice.all)
        def serialize(object_or_collection, context: {}, include: nil)
          return serialize_single(object_or_collection, context:, include:) unless object_or_collection.is_a?(Enumerable)

          object_or_collection.map { |obj| serialize_single(obj, context:, include: include) }
        end

        # @api public
        # Deserializes a hash using this schema's decode transformers.
        #
        # Transforms incoming data by applying decode transformers defined
        # on each attribute. Use this for processing request payloads,
        # webhooks, or any external data.
        #
        # @param hash_or_array [Hash, Array<Hash>] data to deserialize
        # @return [Hash, Array<Hash>] deserialized data
        #
        # @example Deserialize request payload
        #   InvoiceSchema.deserialize(params[:invoice])
        #
        # @example Deserialize a collection
        #   InvoiceSchema.deserialize(params[:invoices])
        def deserialize(hash_or_array)
          return nil if hash_or_array.nil?

          if hash_or_array.is_a?(Array)
            hash_or_array.map { |item| deserialize_single(item) }
          else
            deserialize_single(hash_or_array)
          end
        end

        # @api public
        # Returns the root key for JSON responses.
        #
        # Uses the custom root if defined via {#root}, otherwise derives
        # from the schema type or model name.
        #
        # @return [RootKey] the root key for this schema
        # @see #root
        # @see RootKey
        #
        # @example
        #   InvoiceSchema.root_key.singular  # => "invoice"
        #   InvoiceSchema.root_key.plural    # => "invoices"
        def root_key
          if _root
            RootKey.new(_root[:singular], _root[:plural])
          else
            RootKey.new(type || model_class.model_name.element)
          end
        end

        def model_class
          ensure_auto_detection_complete
          @model_class
        end

        def api_class
          return nil unless name

          namespace = name.deconstantize
          return nil if namespace.blank?

          API.find("/#{namespace.underscore.tr('::', '/')}")
        end

        def resolve_option(name, subkey = nil)
          opt = api_class.adapter.class.options[name]
          return nil unless opt

          if opt.nested? && subkey
            value = _adapter_config.dig(name, subkey)
            value = api_class.adapter_config.dig(name, subkey) if value.nil?
            value.nil? ? opt.children[subkey]&.default : value
          else
            value = _adapter_config[name]
            value = api_class.adapter_config[name] if value.nil?
            value.nil? ? opt.resolved_default : value
          end
        end

        def register_variant(schema:, sti_type:, tag:)
          self.variants = variants.merge(tag => { schema:, sti_type: })
          self._abstract = true
        end

        def sti_base?
          return false if sti_variant?

          discriminator_column.present? && variants.any?
        end

        def sti_variant?
          variant_tag.present?
        end

        def needs_discriminator_transform?
          variants.any? { |tag, variant| tag.to_s != variant[:sti_type] }
        end

        def discriminator_sti_mapping
          variants.transform_values { |variant| variant[:sti_type] }
        end

        def deprecated?
          _deprecated
        end

        def type
          @type || model_class.model_name.element
        end

        def deserialize_single(hash)
          return hash unless hash.is_a?(Hash)

          result = hash.dup

          attribute_definitions.each do |name, definition|
            next unless result.key?(name)

            result[name] = definition.decode(result[name])
          end

          association_definitions.each do |name, definition|
            next unless result.key?(name)

            schema_class = definition.schema_class
            next unless schema_class

            value = result[name]
            result[name] = if definition.collection? && value.is_a?(Array)
                             value.map { |item| schema_class.deserialize(item) }
                           elsif value.is_a?(Hash)
                             schema_class.deserialize(value)
                           else
                             value
                           end
          end

          result
        end

        def serialize_single(obj, context: {}, include: nil)
          if sti_base?
            variant_schema_class = resolve_sti_variant(obj)
            return variant_schema_class.new(obj, context:, include:).as_json if variant_schema_class
          end

          new(obj, context:, include:).as_json
        end

        def resolve_sti_variant(obj)
          sti_type = obj.public_send(discriminator_column)
          variant = variants.values.find { |v| v[:sti_type] == sti_type }
          return nil unless variant

          variant[:schema]
        end

        private

        def ensure_auto_detection_complete
          return if @auto_detection_complete

          @auto_detection_complete = true

          return if @model_class.present?
          return if abstract?

          schema_name = name.demodulize
          model_name = schema_name.delete_suffix('Schema')
          return if model_name.blank?

          namespace = name.deconstantize
          detected = if namespace.present?
                       "#{namespace}::#{model_name}".safe_constantize || model_name.safe_constantize
                     else
                       model_name.safe_constantize
                     end

          if detected.present?
            @model_class = detected
          else
            raise ConfigurationError.new(
              code: :model_not_found,
              detail: "Could not find model '#{model_name}' for #{name}. " \
                      "Either create the model, declare it explicitly with 'model YourModel', " \
                      "or mark this schema as abstract with 'abstract!'",
              path: [],
            )
          end
        end
      end

      def initialize(object, context: {}, include: nil)
        @object = object
        @context = context
        @include = include
      end

      def as_json
        serialized_attributes = {}

        add_discriminator_field(serialized_attributes) if self.class.sti_variant?

        self.class.attribute_definitions.each do |attribute, definition|
          value = respond_to?(attribute) ? public_send(attribute) : object.public_send(attribute)
          value = definition.encode(value)
          serialized_attributes[attribute] = value
        end

        self.class.association_definitions.each do |association, definition|
          next unless should_include_association?(association, definition)

          serialized_attributes[association] = serialize_association(association, definition)
        end

        serialized_attributes
      end

      private

      def add_discriminator_field(serialized_attributes)
        parent_schema = self.class.superclass
        discriminator_name = parent_schema.discriminator_name
        return unless discriminator_name

        variant_tag = self.class.variant_tag

        serialized_attributes[discriminator_name] = variant_tag.to_s
      end

      def serialize_association(name, definition)
        target = object.public_send(name)
        return nil if target.nil?

        schema_class = definition.schema_class || resolve_association_schema(name)
        return nil unless schema_class

        nested_includes = @include[name] || @include[name.to_s] || @include[name.to_sym] if @include.is_a?(Hash)

        if definition.collection?
          target.map { |record| serialize_sti_aware(record, schema_class, nested_includes) }
        else
          serialize_sti_aware(target, schema_class, nested_includes)
        end
      end

      def resolve_association_schema(association_name)
        return nil unless self.class.model_class

        reflection = object.class.reflect_on_association(association_name)
        return nil unless reflection
        return nil if reflection.polymorphic?

        namespace = self.class.name.deconstantize
        "#{namespace}::#{reflection.klass.name.demodulize}Schema".safe_constantize
      end

      def serialize_sti_aware(record, schema_class, nested_includes)
        if schema_class.sti_base?
          variant_schema_class = schema_class.resolve_sti_variant(record)
          return variant_schema_class.new(record, context: context, include: nested_includes).as_json if variant_schema_class
        end

        schema_class.new(record, context: context, include: nested_includes).as_json
      end

      def should_include_association?(name, definition)
        return explicitly_included?(name) unless definition.always_included?
        return true unless circular_reference?(definition)

        false
      end

      def circular_reference?(definition)
        return false unless definition.schema_class

        definition.schema_class.association_definitions.values.any? do |association_definition|
          association_definition.always_included? && association_definition.schema_class == self.class
        end
      end

      def explicitly_included?(name)
        return false if @include.nil?

        case @include
        when Symbol, String
          @include.to_sym == name
        when Array
          include_symbols.include?(name)
        when Hash
          name = name.to_sym
          @include.key?(name) || @include.key?(name.to_s)
        else
          false
        end
      end

      def include_symbols
        @include_symbols ||= @include.map(&:to_sym)
      end
    end
  end
end
