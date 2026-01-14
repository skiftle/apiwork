# frozen_string_literal: true

module Apiwork
  module Export
    class Zod < Base
      export_name :zod
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
        @zod_mapper ||= ZodMapper.new(data, key_format:)
      end

      def typescript_mapper
        @typescript_mapper ||= TypeScriptMapper.new(data, key_format:)
      end

      def surface
        @surface ||= SurfaceResolver.new(data)
      end

      def build_enum_schemas
        return '' if surface.enums.empty?

        surface.enums.map do |name, enum|
          schema_name = zod_mapper.pascal_case(name)
          enum_literal = enum.values.sort.map { |value| "'#{value}'" }.join(', ')
          "export const #{schema_name}Schema = z.enum([#{enum_literal}]);"
        end.join("\n\n")
      end

      def build_type_schemas
        types_hash = surface.types.transform_values(&:to_h)
        sorted_type_names = TypeAnalysis.topological_sort_types(types_hash).map(&:first)

        schemas = sorted_type_names.map do |type_name|
          type = surface.types[type_name]
          if type.union?
            zod_mapper.build_union_schema(type_name, type)
          else
            recursive = TypeAnalysis.circular_reference?(type_name, types_hash[type_name], filter: :custom_only)
            zod_mapper.build_object_schema(type_name, type, recursive:)
          end
        end

        schemas.join("\n\n")
      end

      def build_action_schemas
        schemas = []

        traverse_resources do |resource|
          resource_name = resource.identifier.to_sym
          parent_identifiers = resource.parent_identifiers

          resource.actions.each do |action_name, action|
            request = action.request
            if request && (request.query? || request.body?)
              if request.query?
                schemas << zod_mapper.build_action_request_query_schema(
                  resource_name,
                  action_name,
                  request.query,
                  parent_identifiers:,
                )
              end
              if request.body?
                schemas << zod_mapper.build_action_request_body_schema(
                  resource_name,
                  action_name,
                  request.body,
                  parent_identifiers:,
                )
              end
              schemas << zod_mapper.build_action_request_schema(
                resource_name,
                action_name,
                { body: request.body, query: request.query },
                parent_identifiers:,
              )
            end

            response = action.response
            if response&.no_content?
              schema_name = zod_mapper.action_type_name(resource_name, action_name, 'Response', parent_identifiers:)
              schemas << "export const #{schema_name} = z.never();"
            elsif response&.body?
              schemas << zod_mapper.build_action_response_body_schema(resource_name, action_name, response.body, parent_identifiers:)
              schemas << zod_mapper.build_action_response_schema(resource_name, action_name, { body: response.body }, parent_identifiers:)
            end
          end
        end

        schemas.join("\n\n")
      end

      def build_typescript_types
        all_types = []

        surface.enums.each do |name, enum|
          type_name = typescript_mapper.pascal_case(name)
          type_literal = enum.values.sort.map { |value| "'#{value}'" }.join(' | ')
          all_types << { code: "export type #{type_name} = #{type_literal};", name: type_name }
        end

        surface.types.each do |name, type|
          type_name_pascal = typescript_mapper.pascal_case(name)
          code = if type.union?
                   typescript_mapper.build_union_type(name, type)
                 else
                   typescript_mapper.build_interface(name, type)
                 end
          all_types << { code:, name: type_name_pascal }
        end

        traverse_resources do |resource|
          resource_name = resource.identifier.to_sym
          parent_identifiers = resource.parent_identifiers

          resource.actions.each do |action_name, action|
            request = action.request
            if request && (request.query? || request.body?)
              if request.query?
                type_name = typescript_mapper.action_type_name(resource_name, action_name, 'RequestQuery', parent_identifiers:)
                code = typescript_mapper.build_action_request_query_type(resource_name, action_name, request.query, parent_identifiers:)
                all_types << { code:, name: type_name }
              end

              if request.body?
                type_name = typescript_mapper.action_type_name(resource_name, action_name, 'RequestBody', parent_identifiers:)
                code = typescript_mapper.build_action_request_body_type(resource_name, action_name, request.body, parent_identifiers:)
                all_types << { code:, name: type_name }
              end

              type_name = typescript_mapper.action_type_name(resource_name, action_name, 'Request', parent_identifiers:)
              code = typescript_mapper.build_action_request_type(
                resource_name,
                action_name,
                { body: request.body, query: request.query },
                parent_identifiers:,
              )
              all_types << { code:, name: type_name }
            end

            response = action.response

            if response&.no_content?
              type_name = typescript_mapper.action_type_name(resource_name, action_name, 'Response', parent_identifiers:)
              all_types << { code: "export type #{type_name} = never;", name: type_name }
            elsif response&.body?
              type_name = typescript_mapper.action_type_name(resource_name, action_name, 'ResponseBody', parent_identifiers:)
              code = typescript_mapper.build_action_response_body_type(resource_name, action_name, response.body, parent_identifiers:)
              all_types << { code:, name: type_name }

              type_name = typescript_mapper.action_type_name(resource_name, action_name, 'Response', parent_identifiers:)
              code = typescript_mapper.build_action_response_type(resource_name, action_name, { body: response.body }, parent_identifiers:)
              all_types << { code:, name: type_name }
            end
          end
        end

        all_types.sort_by { |t| t[:name] }.map { |t| t[:code] }.join("\n\n")
      end

      def traverse_resources(resources = data.resources, &block)
        resources.each_value do |resource|
          yield(resource)
          traverse_resources(resource.resources, &block) if resource.resources.any?
        end
      end
    end
  end
end
