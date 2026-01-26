# frozen_string_literal: true

module Apiwork
  module Representation
    # @api public
    # Base class for resource representations.
    #
    # Representations define attributes and associations for serialization.
    # Types and nullability are auto-detected from the model's database columns.
    #
    # @example Basic representation
    #   class InvoiceRepresentation < Apiwork::Representation::Base
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
    #   Marks this representation as abstract.
    #
    #   Abstract representations don't require a model and serve as base classes
    #   for other representations. Use this when creating application-wide base representations.
    #   Subclasses automatically become non-abstract.
    #   @return [void]
    #   @example Application base representation
    #     class ApplicationRepresentation < Apiwork::Representation::Base
    #       abstract!
    #     end
    #
    # @!method abstract?
    #   @api public
    #   Returns whether this representation is abstract.
    #   @return [Boolean] true if abstract
    class Base
      include Abstractable

      # @!method self.attributes
      #   @api public
      #   @return [Hash{Symbol => Attribute}] defined attributes
      class_attribute :attributes, default: {}, instance_accessor: false

      # @!method self.associations
      #   @api public
      #   @return [Hash{Symbol => Association}] defined associations
      class_attribute :associations, default: {}, instance_accessor: false

      # @!method union
      #   @!scope class
      #   @api public
      #   @return [Representation::Union, nil] the union configuration
      class_attribute :union, default: nil, instance_accessor: false

      # @!method tag
      #   @!scope class
      #   @api public
      #   @return [Symbol, nil] the variant's tag, or nil if not a variant
      class_attribute :tag, default: nil, instance_accessor: false
      class_attribute :_root, default: nil, instance_accessor: false
      class_attribute :_adapter_config, default: {}, instance_accessor: false
      class_attribute :_description, default: nil, instance_accessor: false
      class_attribute :_deprecated, default: false, instance_accessor: false
      class_attribute :_example, default: nil, instance_accessor: false

      # @api public
      # @return [Hash] custom context passed during serialization
      attr_reader :context

      # @api public
      # @return [ActiveRecord::Base] the record being serialized
      attr_reader :record

      class << self
        attr_writer :type

        # @api public
        # The model class.
        #
        # By default, the model is auto-detected from the representation name
        # (e.g., InvoiceRepresentation becomes Invoice). Use this to override.
        #
        # @param value [Class] the ActiveRecord model class (optional)
        # @return [Class, nil]
        # @raise [ArgumentError] if value is not a Class
        #
        # @example Explicit model
        #   class InvoiceRepresentation < Apiwork::Representation::Base
        #     model Invoice
        #   end
        #
        # @example Namespaced model
        #   class InvoiceRepresentation < Apiwork::Representation::Base
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
        # Declares the JSON root key for this representation.
        #
        # Adapters can use this to wrap responses in a root key.
        #
        # @param singular [String, Symbol] root key for single records
        # @param plural [String, Symbol] root key for collections (default: singular.pluralize)
        #
        # @example Custom root key
        #   class InvoiceRepresentation < Apiwork::Representation::Base
        #     root :bill, :bills
        #   end
        def root(singular, plural = singular.to_s.pluralize)
          self._root = { plural: plural.to_s, singular: singular.to_s }
        end

        # @api public
        # Configures adapter options for this representation.
        #
        # Use this to override API-level adapter settings for a specific
        # resource. Available options depend on the adapter being used.
        #
        # @yield block for adapter configuration
        # @see Adapter::Base
        #
        # @example Custom pagination for this resource
        #   class ActivityRepresentation < Apiwork::Representation::Base
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
          config = Configuration.new(api_class.adapter_class, _adapter_config)
          config.instance_eval(&block)
        end

        # @api public
        # The merged adapter configuration for this representation.
        #
        # Configuration values are resolved in order:
        # 1. Representation-level (defined in the representation class via `adapter do`)
        # 2. API-level (defined in the API definition via `adapter do`)
        # 3. Adapter defaults (defined in the adapter class)
        #
        # @return [Configuration]
        # @see API::Base#adapter_config
        # @see Adapter::Base
        #
        # @example
        #   representation_class.adapter_config.pagination.default_size
        #   representation_class.adapter_config.pagination.strategy
        def adapter_config
          @adapter_config ||= api_class.adapter_config.merge(_adapter_config)
        end

        # @api public
        # Defines an attribute for serialization and API contracts.
        #
        # Types and nullability are auto-detected from the model's database
        # columns when available.
        #
        # @param name [Symbol] attribute name (must match model attribute)
        # @option options [Symbol] :type data type (:string, :integer, :boolean,
        #   :datetime, :date, :uuid, :decimal, :number, :object, :array)
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
        # @option options [Symbol] :format format hint (:email, :url, :uuid, etc.)
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
          optional: nil,
          sortable: nil,
          type: nil,
          writable: nil,
          &block
        )
          self.attributes = attributes.merge(
            name => Attribute.new(
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
        # @option options [Class] :representation explicit representation class for the association
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
        # @example With explicit representation
        #   has_one :author, representation: UserRepresentation
        #
        # @example Nested attributes
        #   has_one :address, writable: true
        #
        # @example Polymorphic
        #   has_one :imageable, polymorphic: [:product, :user]
        def has_one(
          name,
          deprecated: false,
          description: nil,
          example: nil,
          filterable: false,
          include: :optional,
          nullable: nil,
          optional: nil,
          polymorphic: nil,
          representation: nil,
          sortable: false,
          writable: false
        )
          self.associations = associations.merge(
            name => Association.new(
              name,
              :has_one,
              self,
              deprecated:,
              description:,
              example:,
              filterable:,
              include:,
              nullable:,
              optional:,
              polymorphic:,
              representation:,
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
          deprecated: false,
          description: nil,
          example: nil,
          filterable: false,
          include: :optional,
          nullable: nil,
          optional: nil,
          polymorphic: nil,
          representation: nil,
          sortable: false,
          writable: false
        )
          self.associations = associations.merge(
            name => Association.new(
              name,
              :has_many,
              self,
              allow_destroy:,
              deprecated:,
              description:,
              example:,
              filterable:,
              include:,
              nullable:,
              optional:,
              polymorphic:,
              representation:,
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
          deprecated: false,
          description: nil,
          example: nil,
          filterable: false,
          include: :optional,
          nullable: nil,
          optional: nil,
          polymorphic: nil,
          representation: nil,
          sortable: false,
          writable: false
        )
          self.associations = associations.merge(
            name => Association.new(
              name,
              :belongs_to,
              self,
              deprecated:,
              description:,
              example:,
              filterable:,
              include:,
              nullable:,
              optional:,
              polymorphic:,
              representation:,
              sortable:,
              writable:,
            ),
          )
        end

        # @api public
        # The API-friendly type identifier for this representation.
        #
        # Rails stores full class names in discriminator columns for STI and
        # polymorphic associations (e.g., `"Billing::Invoice"` or `"MyApp::Post"`).
        # These internal names are often acceptable in an API, but can leak
        # implementation details like module structure or naming conventions.
        #
        # Use this to provide a cleaner, user-friendly identifier that adapters
        # can use when serializing and deserializing type information.
        #
        # @param value [Symbol, String] the type identifier
        # @return [Symbol, nil]
        #
        # @example
        #   class CarRepresentation < VehicleRepresentation
        #     type_name :car
        #   end
        #
        #   CarRepresentation.type_name  # => :car
        def type_name(value = nil)
          return @type_name if value.nil?

          @type_name = value.to_sym
        end

        # @api public
        # Sets or gets a description for this representation.
        #
        # Used in generated documentation (OpenAPI, etc.) to describe
        # what this resource represents.
        #
        # @param value [String] description text (optional)
        # @return [String, nil] the description
        #
        # @example
        #   class InvoiceRepresentation < Apiwork::Representation::Base
        #     description 'Represents a customer invoice'
        #   end
        def description(value = nil)
          return _description if value.nil?

          self._description = value
        end

        # @api public
        # Marks this representation as deprecated.
        #
        # Deprecated representations are included in generated documentation
        # with a deprecation notice.
        #
        # @example
        #   class LegacyOrderRepresentation < Apiwork::Representation::Base
        #     deprecated!
        #   end
        def deprecated!
          self._deprecated = true
        end

        # @api public
        # Sets or gets an example value for this representation.
        #
        # Used in generated documentation to show example responses.
        #
        # @param value [Hash] example data (optional)
        # @return [Hash, nil] the example
        #
        # @example
        #   class InvoiceRepresentation < Apiwork::Representation::Base
        #     example { id: 1, total: 99.00, status: 'paid' }
        #   end
        def example(value = nil)
          return _example if value.nil?

          self._example = value
        end

        # @api public
        # Serializes a record or a collection of records using this representation.
        #
        # Converts records to JSON-ready hashes based on
        # attribute and association definitions.
        #
        # @param record_or_collection [ActiveRecord::Base, Array<ActiveRecord::Base>] record(s) to serialize
        # @param context [Hash] context data available during serialization
        # @param include [Symbol, Array, Hash] associations to include
        # @return [Hash, Array<Hash>] serialized data
        #
        # @example Serialize a single record
        #   InvoiceRepresentation.serialize(invoice)
        #
        # @example Serialize with associations
        #   InvoiceRepresentation.serialize(invoice, include: [:customer, :line_items])
        #
        # @example Serialize a collection
        #   InvoiceRepresentation.serialize(Invoice.all)
        def serialize(record_or_collection, context: {}, include: nil)
          if record_or_collection.is_a?(Enumerable)
            record_or_collection.map { |record| serialize_record(record, context:, include:) }
          else
            serialize_record(record_or_collection, context:, include:)
          end
        end

        # @api public
        # Deserializes a hash or an array of hashes using this representation's decode transformers.
        #
        # Transforms incoming data by applying decode transformers defined
        # on each attribute. Use this for processing request payloads,
        # webhooks, or any external data.
        #
        # @param hash_or_array [Hash, Array<Hash>] data to deserialize
        # @return [Hash, Array<Hash>] deserialized data
        #
        # @example Deserialize request payload
        #   InvoiceRepresentation.deserialize(params[:invoice])
        #
        # @example Deserialize a collection
        #   InvoiceRepresentation.deserialize(params[:invoices])
        def deserialize(hash_or_array)
          if hash_or_array.is_a?(Array)
            hash_or_array.map { |hash| deserialize_hash(hash) }
          else
            deserialize_hash(hash_or_array)
          end
        end

        # @api public
        # The root key for JSON responses.
        #
        # Uses the custom root if defined via {#root}, otherwise derives
        # from the representation type or model name.
        #
        # @return [RootKey]
        # @see #root
        # @see RootKey
        #
        # @example
        #   InvoiceRepresentation.root_key.singular  # => "invoice"
        #   InvoiceRepresentation.root_key.plural    # => "invoices"
        def root_key
          if _root
            RootKey.new(_root[:singular], _root[:plural])
          else
            RootKey.new(type || model_class.model_name.element)
          end
        end

        def model_class
          ensure_auto_detection_complete
          ensure_sti_auto_configuration_complete
          @model_class
        end

        def api_class
          return nil unless name

          namespace = name.deconstantize
          return nil if namespace.blank?

          API.find("/#{namespace.underscore.tr('::', '/')}")
        end

        def discriminated?
          ensure_sti_auto_configuration_complete
          union.present? && !variant? && union.variants.any?
        end

        def variant?
          ensure_sti_auto_configuration_complete
          tag.present?
        end

        def resolve_variant(record)
          return nil unless union

          union.resolve(record)&.representation_class
        end

        def deprecated?
          _deprecated
        end

        def type
          @type || model_class.model_name.element
        end

        def polymorphic_association_for_type_column(column_name)
          associations.values.find do |assoc|
            assoc.polymorphic? && assoc.discriminator == column_name
          end
        end

        def sti_union_for_type_column(column_name)
          target_union = union
          target_model = model_class

          if variant? && superclass.respond_to?(:union)
            target_union = superclass.union
            target_model = superclass.model_class
          end

          return nil unless target_union
          return nil unless target_union.variants.any?
          return nil unless target_model.respond_to?(:inheritance_column)

          inheritance_col = target_model.inheritance_column.to_sym
          return nil unless column_name.to_sym == inheritance_col

          target_union
        end

        def deserialize_hash(hash)
          return hash unless hash.is_a?(Hash)

          result = hash.dup

          attributes.each do |name, attribute|
            next unless result.key?(name)

            result[name] = attribute.decode(result[name])
          end

          associations.each do |name, association|
            next unless result.key?(name)

            representation_class = association.representation_class
            next unless representation_class

            value = result[name]
            result[name] = if association.collection? && value.is_a?(Array)
                             value.map { |item| representation_class.deserialize(item) }
                           elsif value.is_a?(Hash)
                             representation_class.deserialize(value)
                           else
                             value
                           end
          end

          result
        end

        def serialize_record(record, context: {}, include: nil)
          if discriminated?
            variant_representation_class = resolve_variant(record)
            return variant_representation_class.new(record, context:, include:).as_json if variant_representation_class
          end

          new(record, context:, include:).as_json
        end

        private

        def ensure_auto_detection_complete
          return if @auto_detection_complete

          @auto_detection_complete = true

          return if @model_class.present?
          return if abstract?

          representation_name = name.demodulize
          model_name = representation_name.delete_suffix('Representation')
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
                      "or mark this representation as abstract with 'abstract!'",
              path: [],
            )
          end
        end

        def ensure_sti_auto_configuration_complete
          return if @sti_auto_configuration_complete

          @sti_auto_configuration_complete = true
          ensure_auto_detection_complete
          return unless @model_class

          auto_configure_sti_base if sti_base_model? && union.nil? && tag.blank?

          return unless sti_subclass_model? && tag.blank? && superclass_is_sti_base?

          auto_register_sti_variant
        end

        def sti_base_model?
          return false unless @model_class
          return false unless @model_class.respond_to?(:inheritance_column)
          return false if @model_class.abstract_class?

          column = @model_class.inheritance_column
          return false unless column

          begin
            return false unless @model_class.column_names.include?(column.to_s)
          rescue ActiveRecord::StatementInvalid, ActiveRecord::NoDatabaseError, ActiveRecord::ConnectionNotEstablished
            return false
          end

          @model_class == @model_class.base_class
        end

        def sti_subclass_model?
          return false unless @model_class
          return false unless @model_class.respond_to?(:base_class)
          return false if @model_class.abstract_class?

          @model_class != @model_class.base_class
        end

        def auto_configure_sti_base
          column = @model_class.inheritance_column.to_sym
          self.union = Union.new(column:, discriminator: column)
        end

        def auto_register_sti_variant
          superclass.send(:ensure_sti_auto_configuration_complete)
          return unless superclass.union

          resolved_tag = (type_name || @model_class.sti_name).to_sym
          self.tag = resolved_tag

          variant = Union::Variant.new(
            representation_class: self,
            tag: resolved_tag,
            type: @model_class.sti_name,
          )
          superclass.union.register(variant)
          superclass._abstract = true
        end

        def superclass_is_sti_base?
          return false unless superclass.respond_to?(:model_class)

          parent_model = superclass.model_class
          parent_model && parent_model == @model_class.base_class
        end
      end

      def initialize(record, context: {}, include: nil)
        @record = record
        @context = context
        @include = include
      end

      def as_json
        fields = {}

        add_discriminator_field(fields) if self.class.variant?

        self.class.attributes.each do |name, attribute|
          value = respond_to?(name) ? public_send(name) : record.public_send(name)
          value = map_type_column_output(name, value)
          value = attribute.encode(value)
          fields[name] = value
        end

        self.class.associations.each do |name, association|
          next unless should_include_association?(name, association)

          fields[name] = serialize_association(name, association)
        end

        fields
      end

      private

      def add_discriminator_field(fields)
        parent_representation = self.class.superclass
        return unless parent_representation.union

        fields[parent_representation.union.discriminator] = self.class.tag.to_s
      end

      def map_type_column_output(attribute_name, value)
        return value if value.nil?

        association = self.class.polymorphic_association_for_type_column(attribute_name)
        if association
          representation_class = association.find_representation_for_type(value)
          return (representation_class.type_name || representation_class.model_class.polymorphic_name).to_s if representation_class
        end

        union = self.class.sti_union_for_type_column(attribute_name)
        if union
          variant = union.variants.values.find { |v| v.type == value }
          return variant.tag.to_s if variant
        end

        value
      end

      def serialize_association(name, association)
        target = record.public_send(name)
        return nil if target.nil?

        representation_class = association.representation_class || resolve_association_representation(name)
        return nil unless representation_class

        nested_includes = @include[name] || @include[name.to_s] || @include[name.to_sym] if @include.is_a?(Hash)

        if association.collection?
          target.map { |record| serialize_variant_aware(record, representation_class, nested_includes) }
        else
          serialize_variant_aware(target, representation_class, nested_includes)
        end
      end

      def resolve_association_representation(association_name)
        return nil unless self.class.model_class

        reflection = record.class.reflect_on_association(association_name)
        return nil unless reflection
        return nil if reflection.polymorphic?

        namespace = self.class.name.deconstantize
        "#{namespace}::#{reflection.klass.name.demodulize}Representation".safe_constantize
      end

      def serialize_variant_aware(record, representation_class, nested_includes)
        if representation_class.discriminated?
          variant_representation_class = representation_class.resolve_variant(record)
          return variant_representation_class.new(record, context: context, include: nested_includes).as_json if variant_representation_class
        end

        representation_class.new(record, context: context, include: nested_includes).as_json
      end

      def should_include_association?(name, association)
        return explicitly_included?(name) unless association.include == :always
        return true unless circular_reference?(association)

        false
      end

      def circular_reference?(association)
        return false unless association.representation_class

        association.representation_class.associations.values.any? do |nested_association|
          nested_association.include == :always && nested_association.representation_class == self.class
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
