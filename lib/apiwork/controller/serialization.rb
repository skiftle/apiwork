# frozen_string_literal: true

module Apiwork
  module Controller
    # Handles schema serialization and response building
    #
    # Provides:
    # - serialize_schema - Serializes objects using Schema class
    # - respond_with - Unified response builder for all actions
    #
    module Serialization
      extend ActiveSupport::Concern

      def serialize_schema(object_or_collection, schema_class: nil)
        schema_class ||= Schema::Resolver.from_scope(object_or_collection, namespace: self.class.name.deconstantize)
        schema_class.serialize(object_or_collection, context: build_schema_context)
      end

      def respond_with(resource_or_collection, options = {})
        meta = options.fetch(:meta, {})
        contract_class_name = options[:contract_class_name]

        # Find ActionDefinition for current action
        action_definition = if contract_class_name
          contract = contract_class_name.constantize
          contract.action_definition(action_name.to_sym)
        else
          find_action_definition
        end

        raise ConfigurationError, "No contract found for #{self.class.name}" unless action_definition

        # Get schema class from contract (may be nil for custom contracts)
        schema_class = action_definition.schema_class

        # Transform meta keys if schema exists
        if meta.present? && schema_class
          meta_key_transform = schema_class.serialize_key_transform
          meta = Apiwork::Transform::Case.hash(meta, meta_key_transform)
        end


        response_data = ResponseRenderer.new(
          controller: self,
          action_definition:,
          schema_class:,
          meta:
        ).perform(resource_or_collection)


        render json: response_data, status: determine_status(resource_or_collection)
      end

      private

      def find_action_definition
        Contract::Resolver.resolve(self.class, action_name.to_sym, metadata: find_action_metadata)
      end

      def determine_status(resource_or_collection)
        if resource_or_collection.respond_to?(:errors) && resource_or_collection.errors.any?
          :unprocessable_content
        elsif request.delete?
          :ok
        elsif request.post?
          :created
        else
          :ok
        end
      end

      def build_schema_context
        {}
      end
    end
  end
end
