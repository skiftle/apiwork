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

        ensure_enum_filter_types_registered

        type_storage = @api.type_system.types
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

        enum_storage = @api.type_system.enums
        enum_storage.each_pair.sort_by { |qualified_name, _| qualified_name.to_s }.each do |qualified_name, metadata|
          enum_data = {
            values: metadata[:values],
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
        payload = if metadata[:payload]
                    metadata[:payload]
                  else
                    expand(metadata[:definition], contract_class: metadata[:scope])
                  end

        expand_union_variants(payload, metadata[:scope]) if payload.is_a?(Hash) && payload[:type] == :union

        payload
      end

      def expand_union_variants(payload, scope)
        return unless payload[:variants]

        payload[:variants] = payload[:variants].map do |variant|
          if variant[:shape_block]
            expanded_shape = expand(variant[:shape_block], contract_class: scope)
            variant = variant.dup
            variant.delete(:shape_block)
            variant[:shape] = expanded_shape
          end
          variant
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

      def ensure_enum_filter_types_registered
        @api.type_system.enums.each_pair do |enum_name, _metadata|
          filter_name = :"#{enum_name}_filter"
          next if @api.type_system.types.key?(filter_name)

          @api.union(filter_name) do
            variant type: enum_name
            variant type: :object, partial: true do
              param :eq, type: enum_name, required: false
              param :in, type: :array, of: enum_name, required: false
            end
          end
        end
      end
    end
  end
end
