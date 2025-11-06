# frozen_string_literal: true

require_relative 'attribute_definition'
require_relative 'root_key'
require_relative 'model/operators'
require_relative 'model/querying'
require_relative 'model/inspection'
require_relative 'model/extension'
require_relative 'model/attribute_definition'
require_relative 'model/association_definition'
require_relative 'serialization'

module Apiwork
  module Schema
    class Base
      include Serialization

      class_attribute :abstract_class, default: false
      class_attribute :_model_class
      class_attribute :attribute_definitions, default: {}
      class_attribute :_serialize_key_transform, default: nil
      class_attribute :_deserialize_key_transform, default: nil
      class_attribute :_auto_include_associations, default: nil
      class_attribute :_validated_includes, default: nil
      class_attribute :_root, default: nil

      attr_reader :object, :context, :includes

      def initialize(object, context: {}, includes: nil)
        @object = object
        @context = context
        @includes = includes
      end

      class << self
        # DSL method for explicit model declaration
        # Only accepts constant references (Zeitwerk autoloading)
        def model(ref = nil)
          if ref
            # Validate that ref is a Class constant
            unless ref.is_a?(Class)
              raise ArgumentError, "model must be a Class constant, got #{ref.class}. " \
                                   "Use: model Post (not 'Post' or :post)"
            end

            # Setting model - store class reference
            self._model_class = ref

            # Activate Model::Extension - this prepends all model-specific functionality
            prepend Model::Extension unless ancestors.include?(Model::Extension)

            # Extend with ActiveRecord-specific modules when model is set
            extend Model::Querying unless singleton_class.included_modules.include?(Model::Querying)
            extend Model::Inspection unless singleton_class.included_modules.include?(Model::Inspection)

            # Override attribute factory method and add association DSL methods
            activate_model_definitions!
          else
            # Getting model
            _model_class
          end
        end

        private

        def activate_model_definitions!
          # Add association_definitions class_attribute
          self.class_attribute :association_definitions, default: {} unless respond_to?(:association_definitions)

          # Override attribute to use Model::AttributeDefinition
          define_singleton_method(:attribute) do |name, **options|
            self.attribute_definitions = attribute_definitions.merge(
              name => Model::AttributeDefinition.new(name, klass: self, **options)
            )
          end

          # Add association DSL methods (only exist in Model)
          define_singleton_method(:has_one) do |name, **options|
            self.association_definitions = association_definitions.merge(
              name => Model::AssociationDefinition.new(name, type: :has_one, klass: self, **options)
            )
            @includes_hash = nil
          end

          define_singleton_method(:has_many) do |name, **options|
            self.association_definitions = association_definitions.merge(
              name => Model::AssociationDefinition.new(name, type: :has_many, klass: self, **options)
            )
            @includes_hash = nil
          end

          define_singleton_method(:belongs_to) do |name, **options|
            self.association_definitions = association_definitions.merge(
              name => Model::AssociationDefinition.new(name, type: :belongs_to, klass: self, **options)
            )
            @includes_hash = nil
          end
        end

        public

        # Note: model_class, model?, and model_class= methods
        # are provided by Model::Extension when model() is called

        # DSL method for explicit root key override
        # Accepts singular form (auto-pluralizes) or explicit singular + plural
        #
        # @example Auto-pluralization
        #   root :article  # => singular: 'article', plural: 'articles'
        #
        # @example Explicit plural (for irregular words)
        #   root :person, :people  # => singular: 'person', plural: 'people'
        #
        def root(singular, plural = nil)
          # Convert to strings
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

        # Note: has_one, has_many, belongs_to methods are added by Model::Extension when model() is called

        attr_writer :type, :default_sort, :default_page_size, :maximum_page_size

        def type
          @type
        end

        # Returns a RootKey object for wrapping resources in responses
        #
        # @return [RootKey] object with singular and plural forms
        # @example
        #   ClientSchema.root_key.singular  # => "client"
        #   ClientSchema.root_key.plural    # => "clients"
        def root_key
          # Priority: explicit root DSL > type attribute
          if _root
            RootKey.new(_root[:singular], _root[:plural])
          else
            RootKey.new(type)
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
            # Base version: return attributes explicitly marked as required
            attribute_definitions
              .select { |_, definition| definition.required? && definition.writable_for?(action) }
              .keys
              .freeze
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
