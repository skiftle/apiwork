# frozen_string_literal: true

require_relative 'attribute_definition'
require_relative 'association_definition'
require_relative 'root_key'
require_relative 'querying/operators'
require_relative 'querying/relation'
require_relative 'querying/filter'
require_relative 'querying/sort'
require_relative 'querying/paginate'
require_relative 'serialization'
require_relative 'querying/includes'

module Apiwork
  module Resource
    class Base
      include Serialization
      include Querying::Filter
      include Querying::Includes
      include Querying::Paginate
      include Querying::Relation
      include Querying::Sort

      class_attribute :abstract_class, default: false
      class_attribute :_model_class
      class_attribute :attribute_definitions, default: {}
      class_attribute :association_definitions, default: {}
      class_attribute :_serialize_key_transform, default: nil
      class_attribute :_deserialize_key_transform, default: nil
      class_attribute :_auto_include_associations, default: nil
      class_attribute :_validated_includes, default: nil

      attr_reader :object, :context, :includes

      def initialize(object, context: {}, includes: nil)
        @object = object
        @context = context
        @includes = includes
      end

      class << self
        # DSL method for explicit model declaration
        # Accepts Class, String, or Symbol for lazy loading
        def model(ref)
          self._model_class = case ref
          when Class then ref
          when String then ref.constantize
          when Symbol then ref.to_s.camelize.constantize
          when nil then nil
          else
            raise ArgumentError, "model must be a Class, String, Symbol, or nil, got #{ref.class}"
          end
        end

        def model_class
          return _model_class if _model_class

          # Auto-detect from Resource class name
          resource_name = name.demodulize.sub(/Resource$/, '')
          resource_name.constantize
        rescue NameError
          nil
        end

        def model_class=(klass)
          self._model_class = klass
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
          @includes_hash = nil
        end

        def has_many(name, **options) # rubocop:disable Naming/PredicatePrefix
          self.association_definitions = association_definitions.merge(
            name => AssociationDefinition.new(name, type: :has_many, klass: self, **options)
          )
          @includes_hash = nil
        end

        def belongs_to(name, **options)
          self.association_definitions = association_definitions.merge(
            name => AssociationDefinition.new(name, type: :belongs_to, klass: self, **options)
          )
          @includes_hash = nil
        end

        attr_writer :type, :default_sort, :default_page_size, :maximum_page_size

        def type
          @type || model_class&.model_name&.element
        end

        # Returns a RootKey object for wrapping resources in responses
        #
        # @return [RootKey] object with singular and plural forms
        # @example
        #   ClientResource.root_key.singular  # => "client"
        #   ClientResource.root_key.plural    # => "clients"
        def root_key
          type_name = type || model_class&.model_name&.element
          RootKey.new(type_name)
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

        def writable_for_action?(writable, action)
          # Backward compatibility method - accepts both Hash and definition object
          if writable.respond_to?(:writable_for?)
            writable.writable_for?(action)
          else
            writable.is_a?(Hash) && writable[:on]&.include?(action)
          end
        end

        def required_attributes_for(action)
          @required_attributes_cache ||= {}
          @required_attributes_cache[action] ||= begin
            return [].freeze if model_class.nil?

            writable_attributes = writable_attributes_for(action)

            required_columns = model_class.columns
                                          .select { |column| !column.null && column.default.nil? }
                                          .map { |column| column.name.to_sym }

            (required_columns & writable_attributes).freeze
          end
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
