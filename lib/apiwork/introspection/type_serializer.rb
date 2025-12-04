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

        type_storage = @api.type_system.types
        type_storage.each_pair.sort_by { |qualified_name, _| qualified_name.to_s }.each do |qualified_name, metadata|
          expanded_shape = metadata[:expanded_payload] ||= expand_payload(metadata)
          description = resolve_type_description(qualified_name, metadata)

          result[qualified_name] = if expanded_shape.is_a?(Hash) && expanded_shape[:type] == :union
                                     expanded_shape.merge(
                                       description:,
                                       example: metadata[:example],
                                       format: metadata[:format],
                                       deprecated: metadata[:deprecated] || false
                                     )
                                   else
                                     {
                                       type: :object,
                                       shape: expanded_shape,
                                       description:,
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
            description: resolve_enum_description(qualified_name, metadata),
            example: metadata[:example],
            deprecated: metadata[:deprecated] || false
          }
          result[qualified_name] = enum_data
        end

        result
      end

      private

      def resolve_type_description(type_name, metadata)
        return metadata[:description] if metadata[:description]

        if metadata[:schema_class].respond_to?(:description)
          schema_desc = metadata[:schema_class].description
          return schema_desc if schema_desc
        end

        i18n_type_description(type_name)
      end

      def i18n_type_description(type_name)
        api_path = @api.metadata.path.delete_prefix('/')

        api_key = :"apiwork.apis.#{api_path}.types.#{type_name}.description"
        result = I18n.t(api_key, default: nil)
        return result if result

        global_key = :"apiwork.types.#{type_name}.description"
        I18n.t(global_key, default: nil)
      end

      def resolve_enum_description(enum_name, metadata)
        return metadata[:description] if metadata[:description]

        api_path = @api.metadata.path.delete_prefix('/')

        api_key = :"apiwork.apis.#{api_path}.types.#{enum_name}.description"
        result = I18n.t(api_key, default: nil)
        return result if result

        global_key = :"apiwork.types.#{enum_name}.description"
        I18n.t(global_key, default: nil)
      end

      def expand_payload(metadata)
        definition_blocks = metadata[:definitions] || metadata[:definition]
        payload = metadata[:payload] || expand(definition_blocks, contract_class: metadata[:scope])

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

      def expand(definitions, contract_class: nil, type_name: nil)
        return nil unless definitions

        temp_contract = contract_class || create_temp_contract

        temp_definition = Apiwork::Contract::Definition.new(
          type: :body,
          contract_class: temp_contract
        )

        Array(definitions).each do |definition_block|
          temp_definition.instance_eval(&definition_block)
        end

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
