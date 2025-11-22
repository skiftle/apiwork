# frozen_string_literal: true

module Apiwork
  module Introspection
    class << self
      def api(api_class)
        ApiSerializer.new(api_class).serialize
      end

      def action_definition(action_definition)
        ActionSerializer.new(action_definition).serialize
      end

      def contract(contract_class, action: nil)
        ContractSerializer.new(contract_class, action: action).serialize
      end

      def definition(definition)
        DefinitionSerializer.new(definition).serialize
      end

      def types(api)
        TypeSerializer.new(api).serialize_types
      end

      def enums(api)
        TypeSerializer.new(api).serialize_enums
      end
    end
  end
end
