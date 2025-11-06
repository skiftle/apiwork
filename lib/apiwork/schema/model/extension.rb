# frozen_string_literal: true

module Apiwork
  module Schema
    module Model
      # Extension - Main ActiveRecord extension for Schema::Base
      # This module is prepended when model() is called, providing model-specific
      # functionality without polluting the base Schema class
      module Extension
        def self.prepended(base)
          base.extend(ClassMethods)
        end

        # Instance method overrides

        # Override: detect_association_resource with ActiveRecord reflection
        def detect_association_resource(association_name)
          reflection = object.class.reflect_on_association(association_name)
          return super unless reflection

          Apiwork::Schema::Resolver.from_association(reflection, self.class)
        end

        module ClassMethods
          # Override: Get model class
          def model_class
            _model_class
          end

          # Override: Check if this schema uses a model
          def model?
            !_model_class.nil?
          end

          # Override: Type with model fallback
          def type
            @type || model_class&.model_name&.element
          end

          # Override: Root key with model fallback
          def root_key
            # Priority: explicit root DSL > type attribute > model name
            if _root
              RootKey.new(_root[:singular], _root[:plural])
            else
              type_name = type || model_class&.model_name&.element
              RootKey.new(type_name)
            end
          end

          # Override: Required attributes with DB introspection
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

          # Override: Prepend serialize to handle ActiveRecord::Relation
          def serialize(object_or_collection, context: {}, includes: nil)
            # Handle ActiveRecord::Relation with eager loading
            if object_or_collection.is_a?(ActiveRecord::Relation)
              if includes.present?
                object_or_collection = apply_includes(object_or_collection, includes)
              elsif auto_include_associations
                object_or_collection = apply_includes(object_or_collection)
              end
            end

            # Delegate to original serialize method
            super(object_or_collection, context: context, includes: includes)
          end
        end
      end
    end
  end
end
