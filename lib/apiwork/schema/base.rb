# frozen_string_literal: true

require_relative 'attribute_definition'
require_relative 'association_definition'
require_relative 'root_key'
require_relative 'operators'
require_relative 'querying'
require_relative 'inspection'
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

      # Detect association resource with ActiveRecord reflection
      def detect_association_resource(association_name)
        return nil unless self.class.respond_to?(:model_class) && self.class.model_class

        reflection = object.class.reflect_on_association(association_name)
        return nil unless reflection

        Apiwork::Schema::Resolver.from_association(reflection, self.class)
      end

      # Auto-detect model class from schema name
      def self.inherited(subclass)
        super
        # Don't run auto-detection here because:
        # 1. abstract_class might be set in the class body (after inherited fires)
        # 2. The class name might not be fully resolved yet with Zeitwerk
        # Instead, we'll run it lazily when someone first accesses model-related features
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

            # Setting model - store class reference and activate
            self._model_class = ref
            activate_model_features

            ref
          else
            # Getting model
            _model_class
          end
        end

        def auto_detect_and_activate_model
          # Skip if model already explicitly set on THIS class (not inherited)
          return if instance_variable_defined?(:@_model_class) && _model_class.present?

          # Skip if abstract (explicitly set on this class, not inherited) or anonymous class
          # We check the instance variable directly to avoid inheriting abstract_class from parent
          return if (instance_variable_defined?(:@abstract_class) && @abstract_class) || name.nil?

          # Derive model class name from schema class name
          # Api::V1::CommentSchema → Comment
          schema_name = name.demodulize
          model_name = schema_name.sub(/Schema$/, '')

          # Skip if no model name after removing Schema suffix
          # This handles edge cases like someone naming a class just "Schema"
          return if model_name.blank?

          # Try to constantize model
          # Try same namespace first: Api::V1::Comment
          # Then try root: Comment
          model_class = try_constantize_model(name.deconstantize, model_name)

          # If found, activate model features
          if model_class.present?
            self._model_class = model_class
            activate_model_features
          end
        end

        def try_constantize_model(namespace, model_name)
          # Try namespaced version first
          if namespace.present?
            full_name = "#{namespace}::#{model_name}"
            begin
              return full_name.constantize
            rescue NameError
              # Fall through to try root namespace
            end
          end

          # Try root namespace
          model_name.constantize
        rescue NameError
          nil
        end

        def activate_model_features
          # Extend with querying and inspection
          extend Querying unless singleton_class.included_modules.include?(Querying)
          extend Inspection unless singleton_class.included_modules.include?(Inspection)

          # Activate model-specific attribute and association definitions
          activate_model_definitions!
        end

        private

        def activate_model_definitions!
          # Add association_definitions class_attribute
          self.class_attribute :association_definitions, default: {} unless respond_to?(:association_definitions)

          # Override attribute to use AttributeDefinition with model support
          define_singleton_method(:attribute) do |name, **options|
            self.attribute_definitions = attribute_definitions.merge(
              name => AttributeDefinition.new(name, klass: self, **options)
            )
          end

          # Add association DSL methods
          define_singleton_method(:has_one) do |name, **options|
            self.association_definitions = association_definitions.merge(
              name => AssociationDefinition.new(name, type: :has_one, klass: self, **options)
            )
            @includes_hash = nil
          end

          define_singleton_method(:has_many) do |name, **options|
            self.association_definitions = association_definitions.merge(
              name => AssociationDefinition.new(name, type: :has_many, klass: self, **options)
            )
            @includes_hash = nil
          end

          define_singleton_method(:belongs_to) do |name, **options|
            self.association_definitions = association_definitions.merge(
              name => AssociationDefinition.new(name, type: :belongs_to, klass: self, **options)
            )
            @includes_hash = nil
          end
        end

        public

        # Get model class
        def model_class
          # Lazy auto-detection on first access
          ensure_auto_detection_complete
          _model_class
        end

        # Check if this schema uses a model
        def model?
          # Lazy auto-detection on first access
          ensure_auto_detection_complete
          _model_class.present?
        end

        # Ensure auto-detection has been attempted (lazy loading)
        def ensure_auto_detection_complete
          # Use instance variable to track per-class (not shared with subclasses)
          return if instance_variable_defined?(:@auto_detection_complete) && @auto_detection_complete
          @auto_detection_complete = true
          auto_detect_and_activate_model
        end

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
          @type || model_class&.model_name&.element
        end

        # Returns a RootKey object for wrapping resources in responses
        #
        # @return [RootKey] object with singular and plural forms
        # @example
        #   ClientSchema.root_key.singular  # => "client"
        #   ClientSchema.root_key.plural    # => "clients"
        def root_key
          # Priority: explicit root DSL > type attribute > model name
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

            required_columns = model_class.columns
                                          .select { |col| !col.null && col.default.nil? }
                                          .map { |col| col.name.to_sym }

            (required_columns & writable_attrs).freeze
          end
        end

        # Override serialize to handle ActiveRecord::Relation
        def serialize(object_or_collection, context: {}, includes: nil)
          # Handle ActiveRecord::Relation with eager loading
          if object_or_collection.is_a?(ActiveRecord::Relation)
            if includes.present?
              object_or_collection = apply_includes(object_or_collection, includes)
            elsif auto_include_associations
              object_or_collection = apply_includes(object_or_collection)
            end
          end

          # Delegate to Serialization module
          super(object_or_collection, context: context, includes: includes)
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
