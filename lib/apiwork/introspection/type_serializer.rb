# frozen_string_literal: true

module Apiwork
  module Introspection
    class TypeSerializer
      def initialize(api)
        @api = api
      end

      def serialize_types
        result = {}

        return result unless @api

        type_storage = @api.descriptors.types_data
        type_storage.each_pair.sort_by { |qualified_name, _| qualified_name.to_s }.each do |qualified_name, metadata|
          expanded_shape = metadata[:expanded_payload] ||= expand_payload(metadata)

          result[qualified_name] = if expanded_shape.is_a?(Hash) && expanded_shape[:type] == :union
                                     expanded_shape.merge(
                                       description: metadata[:description],
                                       example: metadata[:example],
                                       format: metadata[:format],
                                       deprecated: metadata[:deprecated] || false
                                     )
                                   else
                                     {
                                       type: :object,
                                       shape: expanded_shape,
                                       description: metadata[:description],
                                       example: metadata[:example],
                                       format: metadata[:format],
                                       deprecated: metadata[:deprecated] || false
                                     }
                                   end
        end

        result
      end

      def serialize_enums
        result = {}

        return result unless @api

        enum_storage = @api.descriptors.enums_data
        enum_storage.each_pair.sort_by { |qualified_name, _| qualified_name.to_s }.each do |qualified_name, metadata|
          enum_data = {
            values: metadata[:payload],
            description: metadata[:description],
            example: metadata[:example],
            deprecated: metadata[:deprecated] || false
          }
          result[qualified_name] = enum_data
        end

        result
      end

      private

      def expand_payload(metadata)
        if metadata[:payload].is_a?(Hash)
          metadata[:payload]
        elsif metadata[:payload].is_a?(Proc)
          expand(metadata[:payload], contract_class: metadata[:scope], type_name: metadata[:name])
        else
          expand(metadata[:definition] || metadata[:payload], contract_class: metadata[:scope], type_name: metadata[:name])
        end
      end

      def expand(definition, contract_class: nil, type_name: nil)
        temp_contract = contract_class || create_temp_contract

        temp_definition = Apiwork::Contract::Definition.new(
          type: :body,
          contract_class: temp_contract
        )

        temp_definition.instance_eval(&definition)

        DefinitionSerializer.new(temp_definition).serialize
      end

      def create_temp_contract
        contract = Class.new(Apiwork::Contract::Base)
        contract.instance_variable_set(:@api_class, @api)
        contract
      end
    end
  end
end
