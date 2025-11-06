# frozen_string_literal: true

module Apiwork
  module Controller
    module Query
      extend ActiveSupport::Concern

      def query(scope, schema_class_name: nil, resource_class_name: nil)
        # Support legacy resource_class_name parameter (deprecated)
        schema_class_name ||= resource_class_name

        schema_class = if schema_class_name
          # Explicit override
          schema_class_name.constantize
        else
          # Go through Contract → Schema
          contract = Contract::Resolver.call(
            controller_class: self.class,
            action_name: action_name,
            metadata: find_action_metadata
          )

          raise ConfigurationError, "Contract #{contract.class.name} must declare schema" unless contract.class.schema?
          contract.class.schema_class
        end

        result = schema_class.query(scope, action_params)

        # Build pagination metadata if pagination params present
        if action_params.key?(:page)
          @pagination_meta = schema_class.build_meta(result)
        end

        result
      end

      def pagination_meta
        @pagination_meta
      end
    end
  end
end
