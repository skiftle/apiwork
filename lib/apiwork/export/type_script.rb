# frozen_string_literal: true

module Apiwork
  module Export
    class TypeScript < Base
      export_name :typescript
      output :string
      file_extension '.ts'

      option :version, default: '5', enum: %w[4 5], type: :string
      option :key_format, default: :keep, enum: %i[keep camel underscore kebab], type: :symbol

      def generate
        types = []

        surface.enums.each do |name, enum|
          types << {
            code: mapper.build_enum_type(name, enum),
            name: mapper.pascal_case(name),
          }
        end

        types_hash = surface.types.transform_values(&:to_h)
        sorted_type_names = TypeAnalysis.topological_sort_types(types_hash).map(&:first)

        sorted_type_names.each do |type_name|
          type = surface.types[type_name]
          type_name_pascal = mapper.pascal_case(type_name)
          code = if type.union?
                   mapper.build_union_type(type_name, type)
                 else
                   recursive = TypeAnalysis.circular_reference?(type_name, types_hash[type_name], filter: :custom_only)
                   mapper.build_interface(type_name, type, recursive:)
                 end
          types << { code:, name: type_name_pascal }
        end

        traverse_resources do |resource|
          resource_name = resource.identifier.to_sym
          parent_identifiers = resource.parent_identifiers

          resource.actions.each do |action_name, action|
            request = action.request
            if request && (request.query? || request.body?)
              if request.query?
                type_name = mapper.action_type_name(resource_name, action_name, 'RequestQuery', parent_identifiers:)
                code = mapper.build_action_request_query_type(resource_name, action_name, request.query, parent_identifiers:)
                types << { code:, name: type_name }
              end

              if request.body?
                type_name = mapper.action_type_name(resource_name, action_name, 'RequestBody', parent_identifiers:)
                code = mapper.build_action_request_body_type(resource_name, action_name, request.body, parent_identifiers:)
                types << { code:, name: type_name }
              end

              type_name = mapper.action_type_name(resource_name, action_name, 'Request', parent_identifiers:)
              code = mapper.build_action_request_type(resource_name, action_name, { body: request.body, query: request.query }, parent_identifiers:)
              types << { code:, name: type_name }
            end

            response = action.response

            if response&.no_content?
              type_name = mapper.action_type_name(resource_name, action_name, 'Response', parent_identifiers:)
              types << { code: "export type #{type_name} = never;", name: type_name }
            elsif response&.body?
              type_name = mapper.action_type_name(resource_name, action_name, 'ResponseBody', parent_identifiers:)
              code = mapper.build_action_response_body_type(resource_name, action_name, response.body, parent_identifiers:)
              types << { code:, name: type_name }

              type_name = mapper.action_type_name(resource_name, action_name, 'Response', parent_identifiers:)
              code = mapper.build_action_response_type(resource_name, action_name, { body: response.body }, parent_identifiers:)
              types << { code:, name: type_name }
            end
          end
        end

        types.sort_by { |type| type[:name] }.map { |type| type[:code] }.join("\n\n")
      end

      private

      def surface
        @surface ||= SurfaceResolver.new(data)
      end

      def mapper
        @mapper ||= TypeScriptMapper.new(data:, key_format:)
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
