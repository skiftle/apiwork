# frozen_string_literal: true

module Apiwork
  module Spec
    # @api private
    class Typescript < Base
      identifier :typescript
      content_type 'text/plain; charset=utf-8'

      option :version, type: :string, default: '5', enum: %w[4 5]
      option :key_format, type: :symbol, default: :keep, enum: %i[keep camel underscore]

      def self.file_extension
        '.ts'
      end

      def generate
        build_all_typescript_types
      end

      private

      def mapper
        @mapper ||= TypescriptMapper.new(introspection: @data, key_format:)
      end

      def build_all_typescript_types
        all_types = []

        enums.each do |enum_name, enum_data|
          type_name = mapper.pascal_case(enum_name)
          enum_values = enum_data[:values]
          type_literal = enum_values.sort.map { |v| "'#{v}'" }.join(' | ')
          all_types << { name: type_name, code: "export type #{type_name} = #{type_literal};" }
        end

        sorted_types = TypeAnalysis.topological_sort_types(types)
        sorted_types.each do |type_name, type_shape|
          type_name_pascal = mapper.pascal_case(type_name)
          code = if type_shape.is_a?(Hash) && type_shape[:type] == :union
                   mapper.build_union_type(type_name, type_shape)
                 else
                   action_name = type_name.to_s.end_with?('_update_payload') ? 'update' : nil
                   recursive = TypeAnalysis.circular_reference?(type_name, type_shape, filter: :custom_only)
                   mapper.build_interface(type_name, type_shape, action_name: action_name, recursive: recursive)
                 end
          all_types << { name: type_name_pascal, code: code }
        end

        each_resource do |resource_name, resource_data, parent_path|
          each_action(resource_data) do |action_name, action_data|
            request_data = action_data[:request]
            if request_data && (request_data[:query]&.any? || request_data[:body]&.any?)
              if request_data[:query]&.any?
                type_name = mapper.action_type_name(resource_name, action_name, 'RequestQuery', parent_path: parent_path)
                code = mapper.build_action_request_query_type(resource_name, action_name, request_data[:query], parent_path: parent_path)
                all_types << { name: type_name, code: code }
              end

              if request_data[:body]&.any?
                type_name = mapper.action_type_name(resource_name, action_name, 'RequestBody', parent_path: parent_path)
                code = mapper.build_action_request_body_type(resource_name, action_name, request_data[:body], parent_path: parent_path)
                all_types << { name: type_name, code: code }
              end

              type_name = mapper.action_type_name(resource_name, action_name, 'Request', parent_path: parent_path)
              code = mapper.build_action_request_type(resource_name, action_name, request_data, parent_path: parent_path)
              all_types << { name: type_name, code: code }
            end

            response_data = action_data[:response]

            if response_data&.dig(:no_content)
              type_name = mapper.action_type_name(resource_name, action_name, 'Response', parent_path: parent_path)
              all_types << { name: type_name, code: "export type #{type_name} = never;" }
            elsif response_data && response_data[:body]
              type_name = mapper.action_type_name(resource_name, action_name, 'ResponseBody', parent_path: parent_path)
              code = mapper.build_action_response_body_type(resource_name, action_name, response_data[:body], parent_path: parent_path)
              all_types << { name: type_name, code: code }

              type_name = mapper.action_type_name(resource_name, action_name, 'Response', parent_path: parent_path)
              code = mapper.build_action_response_type(resource_name, action_name, response_data, parent_path: parent_path)
              all_types << { name: type_name, code: code }
            end
          end
        end

        all_types.sort_by { |t| t[:name] }.map { |t| t[:code] }.join("\n\n")
      end
    end
  end
end
