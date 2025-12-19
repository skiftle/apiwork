# frozen_string_literal: true

module Apiwork
  module Introspection
    # @api private
    class ContractSerializer
      def initialize(contract_class, action: nil)
        @contract_class = contract_class
        @action = action
      end

      def serialize
        if @action
          action_definition = @contract_class.action_definition(@action)
          return nil unless action_definition

          ActionSerializer.new(action_definition).serialize
        else
          result = { actions: {} }

          actions = available_actions
          actions = @contract_class.action_definitions.keys if actions.empty?

          actions.each do |action_name|
            action_definition = @contract_class.action_definition(action_name)
            result[:actions][action_name] = ActionSerializer.new(action_definition).serialize if action_definition
          end

          result
        end
      end

      private

      def available_actions
        metadata = resource_metadata
        return [] unless metadata

        actions = metadata[:actions]&.keys || []
        actions += metadata[:members]&.keys || []
        actions += metadata[:collections]&.keys || []
        actions
      end

      def resource_metadata
        api = @contract_class.api_class
        return nil unless api&.metadata

        api.metadata.find_resource(resource_name)
      end

      def resource_name
        return nil unless @contract_class.name

        @contract_class.name.demodulize.sub(/Contract$/, '').underscore.pluralize.to_sym
      end
    end
  end
end
