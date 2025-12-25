# frozen_string_literal: true

module Apiwork
  module Introspection
    class ContractSerializer
      def initialize(contract_class, expand: false)
        @contract_class = contract_class
        @expand = expand
      end

      def serialize
        result = { actions: {} }

        actions = available_actions
        actions = @contract_class.action_definitions.keys if actions.empty?

        actions.each do |action_name|
          action_definition = @contract_class.action_definition(action_name)
          result[:actions][action_name] = ActionSerializer.new(action_definition).serialize if action_definition
        end

        types = serialize_types
        enums = serialize_enums

        result[:types] = types if types.any?
        result[:enums] = enums if enums.any?

        result
      end

      private

      def serialize_types
        api_class = @contract_class.api_class
        return {} unless api_class

        type_serializer = TypeSerializer.new(api_class)

        api_class.type_system.types.each_pair
                 .select { |_, metadata| include_scope?(metadata[:scope]) }
                 .sort_by { |name, _| name.to_s }
                 .each_with_object({}) do |(name, metadata), result|
          result[name] = type_serializer.serialize_type(name, metadata)
        end
      end

      def serialize_enums
        api_class = @contract_class.api_class
        return {} unless api_class

        type_serializer = TypeSerializer.new(api_class)

        api_class.type_system.enums.each_pair
                 .select { |_, metadata| include_scope?(metadata[:scope]) }
                 .sort_by { |name, _| name.to_s }
                 .each_with_object({}) do |(name, metadata), result|
          result[name] = type_serializer.serialize_enum(name, metadata)
        end
      end

      def include_scope?(scope)
        return scope == @contract_class unless @expand

        scope.nil? ||
          scope == @contract_class ||
          @contract_class.imports.value?(scope)
      end

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
