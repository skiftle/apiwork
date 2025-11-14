# frozen_string_literal: true

module Apiwork
  module Controller
    # Shared contract and action definition resolution logic
    # Used by both Validation and Serialization modules
    module ContractResolution
      extend ActiveSupport::Concern

      private

      # Find contract for current controller
      def current_contract
        current_action_definition&.contract_class
      end

      # Get current action definition for this action
      def current_action_definition
        @current_action_definition ||= Contract::Resolver.resolve(
          controller_class: self.class,
          action_name: action_name.to_sym,
          metadata: current_action_metadata
        )
      end

      # Get metadata for current action (provided by ActionMetadata concern)
      def current_action_metadata
        return {} unless respond_to?(:find_action_metadata, true)

        find_action_metadata
      end
    end
  end
end
