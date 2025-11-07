# frozen_string_literal: true

module Apiwork
  module Controller
    # Handles schema serialization and response building
    #
    # Provides:
    # - respond_with - Unified response builder for all actions
    #
    module Serialization
      extend ActiveSupport::Concern

      def respond_with(resource_or_collection, meta: {}, contract: nil, status: nil)
        action_definition = if contract
                              contract.action_definition(action_name.to_sym)
                            else
                              find_action_definition
                            end

        raise ConfigurationError, "No contract found for #{self.class.name}" unless action_definition

        schema_class = action_definition.schema_class

        if meta.present? && schema_class
          meta = Apiwork::Transform::Case.hash(meta,
                                               schema_class.serialize_key_transform)
        end

        response = ResponseRenderer.new(
          controller: self,
          action_definition:,
          schema_class:,
          meta:
        ).perform(resource_or_collection)

        render json: response, status: status || determine_status(resource_or_collection)
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
