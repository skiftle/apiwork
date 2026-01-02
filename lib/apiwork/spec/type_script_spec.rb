# frozen_string_literal: true

module Apiwork
  module Spec
    class TypeScriptSpec < Base
      spec_name :typescript
      output :string
      file_extension '.ts'

      option :version, default: '5', enum: %w[4 5], type: :string
      option :key_format, default: :keep, enum: %i[keep camel underscore kebab], type: :symbol

      def generate
        build_all_typescript_types
      end

      private

      def mapper
        @mapper ||= TypeScriptMapper.new(data:, key_format:)
      end

      def build_all_typescript_types
        all_types = []

        data.enums.each do |enum|
          type_name = mapper.pascal_case(enum.name)
          code = mapper.build_enum_type(enum)
          all_types << { code:, name: type_name }
        end

        types_by_name = data.types.index_by(&:name)
        types_hash = data.types.to_h { |t| [t.name, t.to_h.except(:name)] }
        sorted_type_names = TypeAnalysis.topological_sort_types(types_hash).map(&:first)

        sorted_type_names.each do |type_name|
          type = types_by_name[type_name]
          type_name_pascal = mapper.pascal_case(type_name)
          code = if type.union?
                   mapper.build_union_type(type)
                 else
                   action_name = type_name.to_s.end_with?('_update_payload') ? 'update' : nil
                   recursive = TypeAnalysis.circular_reference?(type_name, types_hash[type_name], filter: :custom_only)
                   mapper.build_interface(type, action_name:, recursive:)
                 end
          all_types << { code:, name: type_name_pascal }
        end

        data.each_resource do |resource, parent_path|
          resource.actions.each do |action|
            request = action.request
            if request && (request.query? || request.body?)
              if request.query?
                type_name = mapper.action_type_name(resource.name, action.name, 'RequestQuery', parent_path:)
                code = mapper.build_action_request_query_type(resource.name, action.name, request.query, parent_path:)
                all_types << { code:, name: type_name }
              end

              if request.body?
                type_name = mapper.action_type_name(resource.name, action.name, 'RequestBody', parent_path:)
                code = mapper.build_action_request_body_type(resource.name, action.name, request.body, parent_path:)
                all_types << { code:, name: type_name }
              end

              type_name = mapper.action_type_name(resource.name, action.name, 'Request', parent_path:)
              code = mapper.build_action_request_type(resource.name, action.name, { body: request.body, query: request.query }, parent_path:)
              all_types << { code:, name: type_name }
            end

            response = action.response

            if response&.no_content?
              type_name = mapper.action_type_name(resource.name, action.name, 'Response', parent_path:)
              all_types << { code: "export type #{type_name} = never;", name: type_name }
            elsif response&.body?
              type_name = mapper.action_type_name(resource.name, action.name, 'ResponseBody', parent_path:)
              code = mapper.build_action_response_body_type(resource.name, action.name, response.body, parent_path:)
              all_types << { code:, name: type_name }

              type_name = mapper.action_type_name(resource.name, action.name, 'Response', parent_path:)
              code = mapper.build_action_response_type(resource.name, action.name, { body: response.body }, parent_path:)
              all_types << { code:, name: type_name }
            end
          end
        end

        all_types.sort_by { |t| t[:name] }.map { |t| t[:code] }.join("\n\n")
      end
    end
  end
end
