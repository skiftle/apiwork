# frozen_string_literal: true

module Apiwork
  module Controller
    module Query
      extend ActiveSupport::Concern

      def query(scope)
        # Go through Contract → Schema
        contract = Contract::Resolver.call(
          controller_class: self.class,
          action_name: action_name,
          metadata: find_action_metadata
        )

        raise ConfigurationError, "Contract #{contract.class.name} must declare schema" unless contract.class.schema?
        schema_class = contract.class.schema_class

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
