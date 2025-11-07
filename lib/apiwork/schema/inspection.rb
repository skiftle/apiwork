# frozen_string_literal: true

module Apiwork
  module Schema
    # Inspection - ActiveRecord-specific introspection methods
    # This module is extended into Schema::Base when model() is called
    #
    # Currently, most inspection logic is embedded in AttributeDefinition
    # and AssociationDefinition classes, which already handle the absence
    # of a model_class gracefully. This module can be used for future
    # model-specific inspection methods that operate at the schema level.
    module Inspection
      # Detect association resource class from reflection
      def detect_association_resource(association_name)
        association = model_class.reflect_on_association(association_name)
        return nil unless association

        Apiwork::Schema::Resolver.from_association(association, self)
      end

      # Get all required attributes based on DB constraints
      def required_attributes_for(action)
        attribute_definitions.select do |_name, definition|
          definition.required? && definition.writable_for?(action)
        end.keys
      end

      # Check if attribute exists in model
      def model_has_attribute?(name)
        return false unless model_class

        model_class.column_names.include?(name.to_s) ||
          model_class.instance_methods.include?(name.to_sym)
      end

      # Check if association exists in model
      def model_has_association?(name)
        return false unless model_class

        model_class.reflect_on_association(name).present?
      end
    end
  end
end