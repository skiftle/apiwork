# frozen_string_literal: true

module Apiwork
  module Spec
    class Zod < Base
      spec_name :zod
      output :string
      file_extension '.ts'

      option :version, default: '4', enum: %w[4], type: :string
      option :key_format, default: :keep, enum: %i[keep camel underscore kebab], type: :symbol

      def generate
        parts = []

        parts << "import { z } from 'zod';\n"

        enum_schemas = build_enum_schemas
        if enum_schemas.present?
          parts << enum_schemas
          parts << ''
        end

        type_schemas = build_type_schemas
        if type_schemas.present?
          parts << type_schemas
          parts << ''
        end

        action_schemas = build_action_schemas
        if action_schemas.present?
          parts << action_schemas
          parts << ''
        end

        typescript_types = build_typescript_types
        if typescript_types.present?
          parts << typescript_types
          parts << ''
        end

        parts.join("\n")
      end

      private

      def zod_mapper
        @zod_mapper ||= ZodMapper.new(data:, key_format:)
      end

      def typescript_mapper
        @typescript_mapper ||= TypeScriptMapper.new(data:, key_format:)
      end

      def build_enum_schemas
        return '' if data.enums.empty?

        data.enums.map do |enum|
          schema_name = zod_mapper.pascal_case(enum.name)
          enum_literal = enum.values.sort.map { |v| "'#{v}'" }.join(', ')
          "export const #{schema_name}Schema = z.enum([#{enum_literal}]);"
        end.join("\n\n")
      end

      def build_type_schemas
        types_hash = data.types.to_h { |t| [t.name, t.to_h.except(:name)] }
        sorted_types = TypeAnalysis.topological_sort_types(types_hash)

        schemas = sorted_types.map do |type_name, type_shape|
          if type_shape[:type] == :union
            zod_mapper.build_union_schema(type_name, type_shape)
          else
            action_name = type_name.to_s.end_with?('_update_payload') ? 'update' : nil
            recursive = TypeAnalysis.circular_reference?(type_name, type_shape, filter: :custom_only)
            zod_mapper.build_object_schema(type_name, type_shape, action_name:, recursive:)
          end
        end

        schemas.join("\n\n")
      end

      def build_action_schemas
        schemas = []

        data.each_resource do |resource, parent_path|
          resource.actions.each do |action|
            request = action.request
            if request && (request.query? || request.body?)
              query_hash = request.query.transform_values(&:to_h)
              body_hash = request.body.transform_values(&:to_h)
              request_hash = { body: body_hash, query: query_hash }

              if request.query?
                schemas << zod_mapper.build_action_request_query_schema(
                  resource.name,
                  action.name,
                  query_hash,
                  parent_path:,
                )
              end
              if request.body?
                schemas << zod_mapper.build_action_request_body_schema(
                  resource.name,
                  action.name,
                  body_hash,
                  parent_path:,
                )
              end
              schemas << zod_mapper.build_action_request_schema(resource.name, action.name, request_hash, parent_path:)
            end

            response = action.response
            if response&.no_content?
              schema_name = zod_mapper.action_schema_name(resource.name, action.name, 'Response', parent_path:)
              schemas << "export const #{schema_name} = z.never();"
            elsif response&.body?
              schemas << zod_mapper.build_action_response_body_schema(resource.name, action.name, response.body.to_h, parent_path:)
              schemas << zod_mapper.build_action_response_schema(resource.name, action.name, { body: response.body.to_h }, parent_path:)
            end
          end
        end

        schemas.join("\n\n")
      end

      def build_typescript_types
        all_types = []

        data.enums.each do |enum|
          type_name = typescript_mapper.pascal_case(enum.name)
          type_literal = enum.values.sort.map { |v| "'#{v}'" }.join(' | ')
          all_types << { code: "export type #{type_name} = #{type_literal};", name: type_name }
        end

        types_hash = data.types.to_h { |t| [t.name, t.to_h.except(:name)] }
        types_hash.each do |type_name, type_shape|
          type_name_pascal = typescript_mapper.pascal_case(type_name)
          code = if type_shape[:type] == :union
                   typescript_mapper.build_union_type(type_name, type_shape)
                 else
                   action_name = type_name.to_s.end_with?('_update_payload') ? 'update' : nil
                   recursive = TypeAnalysis.circular_reference?(type_name, type_shape, filter: :custom_only)
                   typescript_mapper.build_interface(type_name, type_shape, action_name:, recursive:)
                 end
          all_types << { code:, name: type_name_pascal }
        end

        data.each_resource do |resource, parent_path|
          resource.actions.each do |action|
            request = action.request
            if request && (request.query? || request.body?)
              query_hash = request.query.transform_values(&:to_h)
              body_hash = request.body.transform_values(&:to_h)
              request_hash = { body: body_hash, query: query_hash }

              if request.query?
                type_name = typescript_mapper.action_type_name(resource.name, action.name, 'RequestQuery', parent_path:)
                code = typescript_mapper.build_action_request_query_type(resource.name, action.name, query_hash, parent_path:)
                all_types << { code:, name: type_name }
              end

              if request.body?
                type_name = typescript_mapper.action_type_name(resource.name, action.name, 'RequestBody', parent_path:)
                code = typescript_mapper.build_action_request_body_type(resource.name, action.name, body_hash, parent_path:)
                all_types << { code:, name: type_name }
              end

              type_name = typescript_mapper.action_type_name(resource.name, action.name, 'Request', parent_path:)
              code = typescript_mapper.build_action_request_type(resource.name, action.name, request_hash, parent_path:)
              all_types << { code:, name: type_name }
            end

            response = action.response

            if response&.no_content?
              type_name = typescript_mapper.action_type_name(resource.name, action.name, 'Response', parent_path:)
              all_types << { code: "export type #{type_name} = never;", name: type_name }
            elsif response&.body?
              type_name = typescript_mapper.action_type_name(resource.name, action.name, 'ResponseBody', parent_path:)
              code = typescript_mapper.build_action_response_body_type(resource.name, action.name, response.body.to_h, parent_path:)
              all_types << { code:, name: type_name }

              type_name = typescript_mapper.action_type_name(resource.name, action.name, 'Response', parent_path:)
              code = typescript_mapper.build_action_response_type(resource.name, action.name, { body: response.body.to_h }, parent_path:)
              all_types << { code:, name: type_name }
            end
          end
        end

        all_types.sort_by { |t| t[:name] }.map { |t| t[:code] }.join("\n\n")
      end
    end
  end
end
