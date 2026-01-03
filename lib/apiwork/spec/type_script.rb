# frozen_string_literal: true

module Apiwork
  module Spec
    class TypeScript < Base
      spec_name :typescript
      output :string
      file_extension '.ts'

      option :version, default: '5', enum: %w[4 5], type: :string
      option :key_format, default: :keep, enum: %i[keep camel underscore kebab], type: :symbol

      def generate
        types = []

        data.enums.each do |name, enum|
          types << {
            code: mapper.build_enum_type(name, enum),
            name: mapper.pascal_case(name),
          }
        end

        types_hash = data.types.transform_values(&:to_h)
        sorted_type_names = TypeAnalysis.topological_sort_types(types_hash).map(&:first)

        sorted_type_names.each do |type_name|
          type = data.types[type_name]
          type_name_pascal = mapper.pascal_case(type_name)
          code = if type.union?
                   mapper.build_union_type(type_name, type)
                 else
                   action_name = type_name.to_s.end_with?('_update_payload') ? 'update' : nil
                   recursive = TypeAnalysis.circular_reference?(type_name, types_hash[type_name], filter: :custom_only)
                   mapper.build_interface(type_name, type, action_name:, recursive:)
                 end
          types << { code:, name: type_name_pascal }
        end

        data.each_resource do |resource, parent_path|
          resource_name = resource.identifier.to_sym
          resource.actions.each do |action_name, action|
            request = action.request
            if request && (request.query? || request.body?)
              if request.query?
                type_name = mapper.action_type_name(resource_name, action_name, 'RequestQuery', parent_path:)
                code = mapper.build_action_request_query_type(resource_name, action_name, request.query, parent_path:)
                types << { code:, name: type_name }
              end

              if request.body?
                type_name = mapper.action_type_name(resource_name, action_name, 'RequestBody', parent_path:)
                code = mapper.build_action_request_body_type(resource_name, action_name, request.body, parent_path:)
                types << { code:, name: type_name }
              end

              type_name = mapper.action_type_name(resource_name, action_name, 'Request', parent_path:)
              code = mapper.build_action_request_type(resource_name, action_name, { body: request.body, query: request.query }, parent_path:)
              types << { code:, name: type_name }
            end

            response = action.response

            if response&.no_content?
              type_name = mapper.action_type_name(resource_name, action_name, 'Response', parent_path:)
              types << { code: "export type #{type_name} = never;", name: type_name }
            elsif response&.body?
              type_name = mapper.action_type_name(resource_name, action_name, 'ResponseBody', parent_path:)
              code = mapper.build_action_response_body_type(resource_name, action_name, response.body, parent_path:)
              types << { code:, name: type_name }

              type_name = mapper.action_type_name(resource_name, action_name, 'Response', parent_path:)
              code = mapper.build_action_response_type(resource_name, action_name, { body: response.body }, parent_path:)
              types << { code:, name: type_name }
            end
          end
        end

        types.sort_by { |t| t[:name] }.map { |t| t[:code] }.join("\n\n")
      end

      private

      def mapper
        @mapper ||= TypeScriptMapper.new(data:, key_format:)
      end
    end
  end
end
