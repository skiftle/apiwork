# frozen_string_literal: true

module Apiwork
  module Representation
    # @api public
    # Base class for representations.
    #
    # Defines how an ActiveRecord model is represented in the API. Drives contracts and runtime behavior.
    # Sensible defaults are auto-detected from database columns but can be overridden. Supports STI and
    # polymorphic associations.
    #
    # @example Basic representation
    #   class InvoiceRepresentation < Apiwork::Representation::Base
    #     attribute :id
    #     attribute :title
    #     attribute :status, filterable: true, sortable: true
    #
    #     belongs_to :customer
    #     has_many :items
    #   end
    #
    # @example Contract
    #   class InvoiceContract < Apiwork::Contract::Base
    #     representation InvoiceRepresentation
    #   end
    #
    # @!scope class
    # @!method abstract!
    #   @api public
    #   Marks this representation as abstract.
    #
    #   Abstract representations don't require a model and serve as base classes for other representations.
    #   Use this when creating application-wide base representations. Subclasses automatically become non-abstract.
    #   @return [void]
    #   @example Application base representation
    #     class ApplicationRepresentation < Apiwork::Representation::Base
    #       abstract!
    #     end
    #
    # @!method abstract?
    #   @api public
    #   Whether this representation is abstract.
    #   @return [Boolean]
    class Base
      include Abstractable

      # @!method self.attributes
      #   @api public
      #   The attributes for this representation.
      #
      #   @return [Hash{Symbol => Attribute}]
      class_attribute :attributes, default: {}, instance_accessor: false

      # @!method self.associations
      #   @api public
      #   The associations for this representation.
      #
      #   @return [Hash{Symbol => Association}]
      class_attribute :associations, default: {}, instance_accessor: false

      # @!method self.inheritance
      #   @api public
      #   The inheritance configuration for this representation.
      #
      #   Auto-configured when the model uses STI and representation classes mirror the model hierarchy.
      #
      #   @return [Representation::Inheritance, nil]
      class_attribute :inheritance, default: nil, instance_accessor: false

      class_attribute :_root, default: nil, instance_accessor: false
      class_attribute :_adapter_config, default: {}, instance_accessor: false
      class_attribute :_description, default: nil, instance_accessor: false
      class_attribute :_deprecated, default: false, instance_accessor: false
      class_attribute :_example, default: nil, instance_accessor: false

      # @api public
      # The serialization context.
      #
      # Passed from controller or directly to {.serialize}. Use for data that isn't on the record, like
      # current user or permissions.
      #
      # @return [Hash]
      #
      # @example Override in controller
      #   def context
      #     { current_user: current_user }
      #   end
      #
      # @example Access in custom attribute
      #   attribute :editable, type: :boolean
      #
      #   def editable
      #     context[:current_user]&.admin?
      #   end
      attr_reader :context

      # @api public
      # The record for this representation.
      #
      # Available in custom attributes and associations.
      #
      # @return [ActiveRecord::Base]
      #
      # @example Custom attribute
      #   attribute :full_name, type: :string
      #
      #   def full_name
      #     "#{record.first_name} #{record.last_name}"
      #   end
      attr_reader :record

      class << self
        # @api public
        # Configures the model class for this representation.
        #
        # Auto-detected from representation name when not set. Use {.model_class} to retrieve.
        #
        # @param value [Class<ActiveRecord::Base>]
        #   The model class.
        # @return [void]
        # @raise [ArgumentError] if value is not a Class
        #
        # @example
        #   model Invoice
        def model(value)
          unless value.is_a?(Class)
            raise ArgumentError,
                  "model must be a Class constant, got #{value.class}. " \
                                                     "Use: model Post (not 'Post' or :post)"
          end
          @model_class = value
        end

        # @api public
        # Configures the JSON root key for this representation.
        #
        # Auto-detected from model name when not set. Use {.root_key} to retrieve.
        #
        # @param singular [String, Symbol]
        #   The singular root key.
        # @param plural [String, Symbol] (singular.pluralize)
        #   The plural root key.
        # @return [void]
        #
        # @example
        #   root :bill, :bills
        def root(singular, plural = singular.to_s.pluralize)
          self._root = { plural: plural.to_s, singular: singular.to_s }
        end

        # @api public
        # Configures adapter options for this representation.
        #
        # Overrides API-level options.
        #
        # @yieldparam adapter [Configuration]
        # @return [void]
        #
        # @example
        #   adapter do
        #     pagination do
        #       strategy :cursor
        #       default_size 50
        #     end
        #   end
        def adapter(&block)
          return unless block

          self._adapter_config = _adapter_config.dup
          config = Configuration.new(api_class.adapter_class, _adapter_config)
          block.arity.positive? ? yield(config) : config.instance_eval(&block)
        end

        def adapter_config
          @adapter_config ||= api_class.adapter_config.merge(_adapter_config)
        end

        # @api public
        # Defines an attribute for this representation.
        #
        # @param name [Symbol]
        #   The attribute name.
        # @param decode [Proc, nil] (nil)
        #   Transform for request input (API to database). Must preserve the attribute type.
        # @param deprecated [Boolean] (false)
        #   Whether deprecated. Metadata included in exports.
        # @param description [String, nil] (nil)
        #   The description. Metadata included in exports.
        # @param empty [Boolean, nil] (nil)
        #   Whether to use empty string instead of `null`. Serializes `nil` as `""` and deserializes `""` as `nil`. Only valid for `:string` type.
        # @param encode [Proc, nil] (nil)
        #   Transform for response output (database to API). Must preserve the attribute type.
        # @param enum [Array, nil] (nil)
        #   The allowed values. If `nil`, auto-detected from Rails enum definition.
        # @param example [Object, nil] (nil)
        #   The example. Metadata included in exports.
        # @param filterable [Boolean] (false)
        #   Whether the attribute is filterable.
        # @param format [Symbol, nil] (nil) [:date, :datetime, :double, :email, :float, :hostname, :int32, :int64, :ipv4, :ipv6, :password, :url, :uuid]
        #   Format hint for exports. Does not change the type, but exports may add validation or
        #   documentation based on it. Valid formats by type: `:decimal`/`:number` (`:double`, `:float`),
        #   `:integer` (`:int32`, `:int64`), `:string` (`:date`, `:datetime`, `:email`, `:hostname`,
        #   `:ipv4`, `:ipv6`, `:password`, `:url`, `:uuid`).
        # @param max [Integer, nil] (nil)
        #   The maximum. For `:array`: size. For `:decimal`, `:integer`, `:number`: value. For `:string`: length.
        # @param min [Integer, nil] (nil)
        #   The minimum. For `:array`: size. For `:decimal`, `:integer`, `:number`: value. For `:string`: length.
        # @param nullable [Boolean, nil] (nil)
        #   Whether the value can be `null`. If `nil` and name maps to a database column, auto-detected from column NULL constraint.
        # @param optional [Boolean, nil] (nil)
        #   Whether the attribute is optional for writes. If `nil` and name maps to a database column,
        #   auto-detected from column default or NULL constraint.
        # @param preload [Symbol, Array, Hash, nil] (nil)
        #   Associations to preload for this attribute. Use when custom attributes depend on associations.
        # @param sortable [Boolean] (false)
        #   Whether the attribute is sortable.
        # @param type [Symbol, nil] (nil) [:array, :binary, :boolean, :date, :datetime, :decimal, :integer, :number, :object, :string, :time, :unknown, :uuid]
        #   The type. If `nil` and name maps to a database column, auto-detected from column type.
        #   Defaults to `:unknown` for json/jsonb columns and when no column exists (custom attributes).
        #   Use an explicit type or block in those cases.
        # @param writable [Boolean, Hash] (false) [Hash: on: :create | :update]
        #   Whether the attribute is writable. Use `{ on: :create }` for immutable fields or
        #   `{ on: :update }` for fields that can only be changed after creation.
        # @yieldparam element [Representation::Element]
        # @return [void]
        #
        # @example Basic
        #   attribute :title
        #   attribute :price, type: :decimal, min: 0
        #   attribute :status, filterable: true, sortable: true
        #
        # @example Custom attribute with preload
        #   attribute :total, type: :decimal, preload: :items
        #
        #   def total
        #     record.items.sum(:amount)
        #   end
        #
        # @example Nested preload
        #   attribute :total_with_tax, type: :decimal, preload: { items: :tax_rate }
        #
        #   def total_with_tax
        #     record.items.sum { |item| item.amount * (1 + item.tax_rate.rate) }
        #   end
        #
        # @example Inline type for JSON column
        #   attribute :settings do
        #     object do
        #       string :theme
        #       boolean :notifications
        #     end
        #   end
        #
        # @example Encode/decode transforms
        #   attribute :status, encode: ->(value) { value.upcase }, decode: ->(value) { value.downcase }
        #
        # @example Writable only on create
        #   attribute :slug, writable: { on: :create }
        #
        # @example Explicit enum values
        #   attribute :priority, enum: [:low, :medium, :high]
        #
        # @example Multiple preloads
        #   attribute :summary, type: :string, preload: [:items, :customer]
        #
        #   def summary
        #     "#{record.customer.name}: #{record.items.count} items"
        #   end
        def attribute(
          name,
          decode: nil,
          deprecated: false,
          description: nil,
          empty: nil,
          encode: nil,
          enum: nil,
          example: nil,
          filterable: false,
          format: nil,
          max: nil,
          min: nil,
          nullable: nil,
          optional: nil,
          preload: nil,
          sortable: false,
          type: nil,
          writable: false,
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
              preload:,
              sortable:,
              type:,
              writable:,
              &block
            ),
          )
        end

        # @api public
        # Defines a has_one association for this representation.
        #
        # @param name [Symbol]
        #   The association name.
        # @param deprecated [Boolean] (false)
        #   Whether deprecated. Metadata included in exports.
        # @param description [String, nil] (nil)
        #   The description. Metadata included in exports.
        # @param example [Object, nil] (nil)
        #   The example. Metadata included in exports.
        # @param filterable [Boolean] (false)
        #   Whether the association is filterable.
        # @param include [Symbol] (:optional) [:always, :optional]
        #   The inclusion strategy. `:always` includes automatically but has circular reference protection.
        # @param nullable [Boolean, nil] (nil)
        #   Whether the value can be `null`.
        # @param representation [Class<Representation::Base>, nil] (nil)
        #   The representation class. If `nil`, inferred from the associated model in the same
        #   namespace (e.g., `CustomerRepresentation` for `Customer`).
        # @param sortable [Boolean] (false)
        #   Whether the association is sortable.
        # @param writable [Boolean, Hash] (false) [Hash: on: :create | :update]
        #   Whether the association is writable. Use `{ on: :create }` for immutable associations or
        #   `{ on: :update }` for associations that can only be changed after creation.
        # @return [void]
        #
        # @example Basic
        #   has_one :profile
        #
        # @example Explicit representation
        #   has_one :author, representation: AuthorRepresentation
        #
        # @example Always included
        #   has_one :customer, include: :always
        #
        # @example Custom association
        #   has_one :profile
        #
        #   def profile
        #     record.profile || record.build_profile
        #   end
        def has_one(
          name,
          deprecated: false,
          description: nil,
          example: nil,
          filterable: false,
          include: :optional,
          nullable: nil,
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
              representation:,
              sortable:,
              writable:,
            ),
          )
        end

        # @api public
        # Defines a has_many association for this representation.
        #
        # @param name [Symbol]
        #   The association name.
        # @param allow_destroy [Boolean] (false)
        #   Whether nested records can be destroyed. Auto-detected from model nested_attributes_options.
        # @param deprecated [Boolean] (false)
        #   Whether deprecated. Metadata included in exports.
        # @param description [String, nil] (nil)
        #   The description. Metadata included in exports.
        # @param example [Object, nil] (nil)
        #   The example. Metadata included in exports.
        # @param filterable [Boolean] (false)
        #   Whether the association is filterable.
        # @param include [Symbol] (:optional) [:always, :optional]
        #   The inclusion strategy. `:always` includes automatically but has circular reference protection.
        # @param nullable [Boolean, nil] (nil)
        #   Whether the value can be `null`.
        # @param representation [Class<Representation::Base>, nil] (nil)
        #   The representation class. If `nil`, inferred from the associated model in the same
        #   namespace (e.g., `CustomerRepresentation` for `Customer`).
        # @param sortable [Boolean] (false)
        #   Whether the association is sortable.
        # @param writable [Boolean, Hash] (false) [Hash: on: :create | :update]
        #   Whether the association is writable. Use `{ on: :create }` for immutable associations or
        #   `{ on: :update }` for associations that can only be changed after creation.
        # @return [void]
        # @see #has_one
        #
        # @example Basic
        #   has_many :items
        #
        # @example Explicit representation
        #   has_many :comments, representation: CommentRepresentation
        #
        # @example Always included
        #   has_many :items, include: :always
        #
        # @example Custom association
        #   has_many :items
        #
        #   def items
        #     record.items.limit(5)
        #   end
        def has_many(
          name,
          allow_destroy: false,
          deprecated: false,
          description: nil,
          example: nil,
          filterable: false,
          include: :optional,
          nullable: nil,
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
              representation:,
              sortable:,
              writable:,
            ),
          )
        end

        # @api public
        # Defines a belongs_to association for this representation.
        #
        # @param name [Symbol]
        #   The association name.
        # @param deprecated [Boolean] (false)
        #   Whether deprecated. Metadata included in exports.
        # @param description [String, nil] (nil)
        #   The description. Metadata included in exports.
        # @param example [Object, nil] (nil)
        #   The example. Metadata included in exports.
        # @param filterable [Boolean] (false)
        #   Whether the association is filterable.
        # @param include [Symbol] (:optional) [:always, :optional]
        #   The inclusion strategy. `:always` includes automatically but has circular reference protection.
        # @param nullable [Boolean, nil] (nil)
        #   Whether the value can be `null`. If `nil`, auto-detected from foreign key column NULL constraint.
        # @param polymorphic [Array<Class<Representation::Base>>, nil] (nil)
        #   The allowed representation classes for polymorphic associations.
        # @param representation [Class<Representation::Base>, nil] (nil)
        #   The representation class. If `nil`, inferred from the associated model in the same
        #   namespace (e.g., `CustomerRepresentation` for `Customer`).
        # @param sortable [Boolean] (false)
        #   Whether the association is sortable.
        # @param writable [Boolean, Hash] (false) [Hash: on: :create | :update]
        #   Whether the association is writable. Use `{ on: :create }` for immutable associations or
        #   `{ on: :update }` for associations that can only be changed after creation.
        # @return [void]
        # @see #has_one
        #
        # @example Basic
        #   belongs_to :customer
        #
        # @example Explicit representation
        #   belongs_to :author, representation: AuthorRepresentation
        #
        # @example Always included
        #   belongs_to :customer, include: :always
        #
        # @example Polymorphic
        #   belongs_to :commentable, polymorphic: [PostRepresentation, CustomerRepresentation]
        #
        # @example Custom association
        #   belongs_to :customer
        #
        #   def customer
        #     record.customer || Customer.default
        #   end
        def belongs_to(
          name,
          deprecated: false,
          description: nil,
          example: nil,
          filterable: false,
          include: :optional,
          nullable: nil,
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
              polymorphic:,
              representation:,
              sortable:,
              writable:,
            ),
          )
        end

        # @api public
        # The type name for this representation.
        #
        # Overrides the model's default for STI and polymorphic types.
        #
        # @param value [String, Symbol, nil] (nil)
        #   The type name.
        # @return [String, nil]
        # @see .sti_name
        # @see .polymorphic_name
        #
        # @example
        #   type_name :person
        def type_name(value = nil)
          return @type_name = value.to_s if value

          @type_name
        end

        # @api public
        # The STI name for this representation.
        #
        # Uses {.type_name} if set, otherwise the model's `sti_name`.
        #
        # @return [String]
        def sti_name
          @type_name || model_class.sti_name
        end

        # @api public
        # The polymorphic name for this representation.
        #
        # Uses {.type_name} if set, otherwise the model's `polymorphic_name`.
        #
        # @return [String]
        def polymorphic_name
          @type_name || model_class.polymorphic_name
        end

        # @api public
        # Whether this representation is an STI subclass.
        #
        # @return [Boolean]
        def subclass?
          superclass.respond_to?(:inheritance) && superclass.inheritance&.subclass?(self)
        end

        # @api public
        # The description for this representation.
        #
        # Metadata included in exports.
        #
        # @param value [String, nil] (nil)
        #   The description.
        # @return [String, nil]
        #
        # @example
        #   description 'A customer invoice'
        def description(value = nil)
          return _description if value.nil?

          self._description = value
        end

        # @api public
        # Marks this representation as deprecated.
        #
        # Metadata included in exports.
        #
        # @return [void]
        #
        # @example
        #   deprecated!
        def deprecated!
          self._deprecated = true
        end

        # @api public
        # The example value for this representation.
        #
        # Metadata included in exports.
        #
        # @param value [Hash, nil] (nil)
        #   The example.
        # @return [Hash, nil]
        #
        # @example
        #   example id: 1, total: 99.00, status: 'paid'
        def example(value = nil)
          return _example if value.nil?

          self._example = value
        end

        # @api public
        # Serializes a record or collection to JSON-ready hashes.
        #
        # @param record_or_collection [ActiveRecord::Base, Array<ActiveRecord::Base>]
        #   The record or collection to serialize.
        # @param context [Hash] ({})
        #   The serialization context.
        # @param include [Symbol, Array, Hash, nil] (nil)
        #   The associations to include.
        # @return [Hash, Array<Hash>]
        #
        # @example Basic
        #   InvoiceRepresentation.serialize(invoice)
        #   # => { id: 1, total: 99.00, status: 'paid' }
        #
        # @example Collection
        #   InvoiceRepresentation.serialize(invoices)
        #   # => [{ id: 1, ... }, { id: 2, ... }]
        #
        # @example With associations
        #   InvoiceRepresentation.serialize(invoice, include: [:customer, :items])
        #   # => { id: 1, ..., customer: { id: 1, name: 'Acme' }, items: [...] }
        #
        # @example Nested associations
        #   InvoiceRepresentation.serialize(invoice, include: { customer: [:address] })
        #   # => { id: 1, ..., customer: { id: 1, name: 'Acme', address: { ... } } }
        def serialize(record_or_collection, context: {}, include: nil)
          if record_or_collection.is_a?(Enumerable)
            record_or_collection.map { |record| serialize_record(record, context:, include:) }
          else
            serialize_record(record_or_collection, context:, include:)
          end
        end

        # @api public
        # Deserializes using this representation's decode transformers.
        #
        # @param hash_or_array [Hash, Array<Hash>]
        #   The hash or array of hashes to deserialize.
        # @return [Hash, Array<Hash>]
        #
        # @example
        #   InvoiceRepresentation.deserialize(params[:invoice])
        def deserialize(hash_or_array)
          if hash_or_array.is_a?(Array)
            hash_or_array.map { |hash| deserialize_hash(hash) }
          else
            deserialize_hash(hash_or_array)
          end
        end

        # @api public
        # The root key for this representation.
        #
        # Derived from model name when {.root} is not set.
        #
        # @return [RootKey]
        def root_key
          if _root
            RootKey.new(_root[:singular], _root[:plural])
          else
            RootKey.new(model_class.model_name.element)
          end
        end

        # @api public
        # The model class for this representation.
        #
        # Auto-detected from representation name or set via {.model}.
        #
        # @return [Class<ActiveRecord::Base>]
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

        # @api public
        # Whether this representation is deprecated.
        #
        # @return [Boolean]
        def deprecated?
          _deprecated
        end

        def preloads
          attributes.values.filter_map(&:preload)
        end

        def polymorphic_association_for_type_column(column_name)
          associations.values.find do |assoc|
            assoc.polymorphic? && assoc.discriminator == column_name
          end
        end

        def inheritance_for_column(column_name)
          target_class = subclass? ? superclass : self
          target_inheritance = target_class.inheritance
          target_model = target_class.model_class

          return nil unless target_inheritance&.subclasses&.any?
          return nil unless target_model.respond_to?(:inheritance_column)

          target_inheritance if column_name.to_sym == target_model.inheritance_column.to_sym
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
          if inheritance&.subclasses&.any?
            subclass_representation = inheritance.resolve(record)
            return subclass_representation.new(record, context:, include:).as_json if subclass_representation
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

          auto_configure_inheritance if sti_base_model? && inheritance.nil?

          return unless sti_subclass_model? && superclass_is_sti_base? && !subclass?

          auto_register_subclass
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

        def auto_configure_inheritance
          self.inheritance = Inheritance.new(self)
        end

        def auto_register_subclass
          superclass.send(:ensure_sti_auto_configuration_complete)
          return unless superclass.inheritance

          superclass.inheritance.register(self)
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

        add_discriminator_field(fields) if self.class.subclass?

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
        return unless parent_representation.inheritance

        fields[parent_representation.inheritance.column] = self.class.sti_name
      end

      def map_type_column_output(attribute_name, value)
        return value if value.nil?

        association = self.class.polymorphic_association_for_type_column(attribute_name)
        if association
          representation_class = association.find_representation_for_type(value)
          return representation_class.polymorphic_name if representation_class
        end

        inheritance = self.class.inheritance_for_column(attribute_name)
        if inheritance
          klass = inheritance.subclasses.find { |subclass| subclass.model_class.sti_name == value }
          return klass.sti_name if klass
        end

        value
      end

      def serialize_association(name, association)
        target = respond_to?(name) ? public_send(name) : record.public_send(name)
        return nil if target.nil?

        representation_class = association.representation_class
        return nil unless representation_class

        nested_includes = @include[name] || @include[name.to_s] || @include[name.to_sym] if @include.is_a?(Hash)

        if association.collection?
          target.map { |record| serialize_variant_aware(record, representation_class, nested_includes) }
        else
          serialize_variant_aware(target, representation_class, nested_includes)
        end
      end

      def serialize_variant_aware(record, representation_class, nested_includes)
        if representation_class.inheritance&.subclasses&.any?
          subclass_representation = representation_class.inheritance.resolve(record)
          return subclass_representation.new(record, context: context, include: nested_includes).as_json if subclass_representation
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
