# frozen_string_literal: true

module Apiwork
  module Adapter
    class ContractTypeRegistrar
      def initialize(contract_class)
        @contract_class = contract_class
      end

      def type(name, &block) = @contract_class.type(name, &block)
      def enum(name, values:) = @contract_class.enum(name, values:)
      def union(name, discriminator: nil, &block) = @contract_class.union(name, discriminator:, &block)
      def global_type(name, &block) = @contract_class.global_type(name, &block)

      def resolve_type(name) = @contract_class.resolve_type(name)
      def scoped_type_name(name) = @contract_class.scoped_type_name(name)
      def scoped_enum_name(name) = @contract_class.scoped_enum_name(name)

      def define_action(name) = @contract_class.define_action(name)

      def find_contract_for_schema(schema) = @contract_class.find_contract_for_schema(schema)
      def import(contract, as:) = @contract_class.import(contract, as:)
      def imports = @contract_class.imports
    end
  end
end
