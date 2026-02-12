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
      #   Subclasses share the parent's inheritance configuration.
      #
      #   @return [Representation::Inheritance, nil]
      class_attribute :inheritance, default: nil, instance_accessor: false

      class_attribute :_adapter_config, default: {}, instance_accessor: false

      # @!method context
      #   @api public
      #   The serialization context.
      #
      #   Passed from controller or directly to {.serialize}. Use for data that isn't on the record, like
      #   current user or permissions.
      #
      #   @return [Hash]
      #
      #   @example Override in controller
      #     def context
      #       { current_user: current_user }
      #     end
      #
      #   @example Access in custom attribute
      #     attribute :editable, type: :boolean
      #
      #     def editable
      #       context[:current_user]&.admin?
      #     end
      #
      # @!method record
      #   @api public
      #   The record for this representation.
      #
      #   Available in custom attributes and associations.
      #
      #   @return [ActiveRecord::Base]
      #
      #   @example Custom attribute
      #     attribute :full_name, type: :string
      #
      #     def full_name
      #       "#{record.first_name} #{record.last_name}"
      #     end
      attr_reader :context,
                  :record

      class << self
        # @api public
        # Configures the model class for this representation.
        #
        # Auto-detected from representation name when not set. Use {.model_class} to retrieve.
        #
        # @param value [Class<ActiveRecord::Base>]
        #   The model class.
        # @return [void]
        # @raise [ArgumentError] if value is not an ActiveRecord model class
        #
        # @example
        #   model Invoice
        def model(value)
          unless value.is_a?(Class)
            raise ArgumentError,
                  "model must be an ActiveRecord model class, got #{value.class}. " \
                                                                 "Use: model Post (not 'Post' or :post)"
          end
          unless value < ActiveRecord::Base
            raise ArgumentError,
                  "model must be an ActiveRecord model class, got #{value}"
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
          @root = { plural: plural.to_s, singular: singular.to_s }
        end

        # @api public
        # Configures adapter options for this representation.
        #
        # Overrides API-level options. Subclasses inherit parent adapter options.
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

        # @api public
        # Defines an attribute for this representation.
        #
        # Subclasses inherit parent attributes.
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
        # @param writable [Boolean, Symbol] (false) [:create, :update]
        #   The write access. `true` for both create and update, `:create` for create only, `:update` for update only.
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
        #   attribute :slug, writable: :create
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
        # Subclasses inherit parent associations.
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
        #   The inclusion mode.
        # @param nullable [Boolean, nil] (nil)
        #   Whether the association can be `null`.
        # @param representation [Class<Representation::Base>, nil] (nil)
        #   The representation class. If `nil`, inferred from the associated model in the same
        #   namespace (e.g., `CustomerRepresentation` for `Customer`).
        # @param sortable [Boolean] (false)
        #   Whether the association is sortable.
        # @param writable [Boolean, Symbol] (false) [:create, :update]
        #   The write access. `true` for both create and update, `:create` for create only, `:update` for update only.
        #   Requires `accepts_nested_attributes_for` on the model, where `allow_destroy: true` also enables deletion.
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
        # Subclasses inherit parent associations.
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
        #   The inclusion mode.
        # @param representation [Class<Representation::Base>, nil] (nil)
        #   The representation class. If `nil`, inferred from the associated model in the same
        #   namespace (e.g., `CustomerRepresentation` for `Customer`).
        # @param sortable [Boolean] (false)
        #   Whether the association is sortable.
        # @param writable [Boolean, Symbol] (false) [:create, :update]
        #   The write access. `true` for both create and update, `:create` for create only, `:update` for update only.
        #   Requires `accepts_nested_attributes_for` on the model, where `allow_destroy: true` also enables deletion.
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
          deprecated: false,
          description: nil,
          example: nil,
          filterable: false,
          include: :optional,
          representation: nil,
          sortable: false,
          writable: false
        )
          self.associations = associations.merge(
            name => Association.new(
              name,
              :has_many,
              self,
              deprecated:,
              description:,
              example:,
              filterable:,
              include:,
              representation:,
              sortable:,
              writable:,
            ),
          )
        end

        # @api public
        # Defines a belongs_to association for this representation.
        #
        # Subclasses inherit parent associations.
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
        #   The inclusion mode.
        # @param nullable [Boolean, nil] (nil)
        #   Whether the association can be `null`. If `nil`, auto-detected from foreign key column NULL constraint.
        # @param polymorphic [Array<Class<Representation::Base>>, nil] (nil)
        #   The allowed representation classes for polymorphic associations.
        # @param representation [Class<Representation::Base>, nil] (nil)
        #   The representation class. If `nil`, inferred from the associated model in the same
        #   namespace (e.g., `CustomerRepresentation` for `Customer`).
        # @param sortable [Boolean] (false)
        #   Whether the association is sortable.
        # @param writable [Boolean, Symbol] (false) [:create, :update]
        #   The write access. `true` for both create and update, `:create` for create only, `:update` for update only.
        #   Requires `accepts_nested_attributes_for` on the model, where `allow_destroy: true` also enables deletion.
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
          return @description if value.nil?

          @description = value
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
          @deprecated = true
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
          return @example if value.nil?

          @example = value
        end

        # @api public
        # Transforms a record or an array of records to hashes.
        #
        # Applies attribute encoders, maps STI and polymorphic type names,
        # and recursively serializes nested associations.
        #
        # @param resource [ActiveRecord::Base, Array<ActiveRecord::Base>]
        #   The resource to serialize.
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
        def serialize(resource, context: {}, include: nil)
          if resource.is_a?(Enumerable)
            resource.map { |record| serialize_record(record, context:, include:) }
          else
            serialize_record(resource, context:, include:)
          end
        end

        # @api public
        # Transforms a hash or an array of hashes for records.
        #
        # Applies attribute decoders, maps STI and polymorphic type names,
        # and recursively deserializes nested associations.
        #
        # @param payload [Hash, Array<Hash>]
        #   The payload to deserialize.
        # @return [Hash, Array<Hash>]
        #
        # @example
        #   InvoiceRepresentation.deserialize(params[:invoice])
        def deserialize(payload)
          Deserializer.new(self).deserialize(payload)
        end

        # @api public
        # The root key for this representation.
        #
        # Derived from model name when {.root} is not set.
        #
        # @return [RootKey]
        def root_key
          if @root
            RootKey.new(@root[:singular], @root[:plural])
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

        # @api public
        # Whether this representation is deprecated.
        #
        # @return [Boolean]
        def deprecated?
          @deprecated == true
        end

        def adapter_config
          @adapter_config ||= api_class.adapter_config.merge(_adapter_config)
        end

        def api_class
          return nil unless name

          namespace = name.deconstantize
          return nil if namespace.blank?

          API.find("/#{namespace.underscore.tr('::', '/')}")
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

          detected = ModelDetector.new(self).detect
          @model_class = detected if detected
        end

        def ensure_sti_auto_configuration_complete
          return if @sti_auto_configuration_complete

          @sti_auto_configuration_complete = true
          ensure_auto_detection_complete
          return unless @model_class

          model_detector = ModelDetector.new(self)

          auto_configure_inheritance if model_detector.sti_base?(@model_class) && inheritance.nil?

          return unless model_detector.sti_subclass?(@model_class)
          return unless model_detector.superclass_is_sti_base?(@model_class)
          return if subclass?

          auto_register_subclass
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
      end

      def initialize(record, context: {}, include: nil)
        @record = record
        @context = context
        @include = include
      end

      def as_json
        Serializer.new(self, @include).serialize
      end
    end
  end
end
