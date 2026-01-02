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
          code = mapper.build_enum_type(enum.name, enum.to_h.except(:name))
          all_types << { code:, name: type_name }
        end

        types_hash = data.types.to_h { |t| [t.name, t.to_h.except(:name)] }
        sorted_types = TypeAnalysis.topological_sort_types(types_hash)
        sorted_types.each do |type_name, type_shape|
          type_name_pascal = mapper.pascal_case(type_name)
          code = if type_shape[:type] == :union
                   mapper.build_union_type(type_name, type_shape, description: type_shape[:description])
                 else
                   action_name = type_name.to_s.end_with?('_update_payload') ? 'update' : nil
                   recursive = TypeAnalysis.circular_reference?(type_name, type_shape, filter: :custom_only)
                   mapper.build_interface(
                     type_name,
                     type_shape,
                     action_name:,
                     recursive:,
                     description: type_shape[:description],
                     example: type_shape[:example],
                   )
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
                type_name = mapper.action_type_name(resource.name, action.name, 'RequestQuery', parent_path:)
                code = mapper.build_action_request_query_type(resource.name, action.name, query_hash, parent_path:)
                all_types << { code:, name: type_name }
              end

              if request.body?
                type_name = mapper.action_type_name(resource.name, action.name, 'RequestBody', parent_path:)
                code = mapper.build_action_request_body_type(resource.name, action.name, body_hash, parent_path:)
                all_types << { code:, name: type_name }
              end

              type_name = mapper.action_type_name(resource.name, action.name, 'Request', parent_path:)
              code = mapper.build_action_request_type(resource.name, action.name, request_hash, parent_path:)
              all_types << { code:, name: type_name }
            end

            response = action.response

            if response&.no_content?
              type_name = mapper.action_type_name(resource.name, action.name, 'Response', parent_path:)
              all_types << { code: "export type #{type_name} = never;", name: type_name }
            elsif response&.body?
              type_name = mapper.action_type_name(resource.name, action.name, 'ResponseBody', parent_path:)
              code = mapper.build_action_response_body_type(resource.name, action.name, response.body.to_h, parent_path:)
              all_types << { code:, name: type_name }

              type_name = mapper.action_type_name(resource.name, action.name, 'Response', parent_path:)
              code = mapper.build_action_response_type(resource.name, action.name, { body: response.body.to_h }, parent_path:)
              all_types << { code:, name: type_name }
            end
          end
        end

        all_types.sort_by { |t| t[:name] }.map { |t| t[:code] }.join("\n\n")
      end
    end
  end
end
