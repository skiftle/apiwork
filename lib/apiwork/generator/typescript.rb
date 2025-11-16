# frozen_string_literal: true

module Apiwork
  module Generator
    class Typescript < Base
      generator_name :typescript
      content_type 'text/plain; charset=utf-8'

      VALID_VERSIONS = %w[4 5].freeze

      def self.file_extension
        '.ts'
      end

      def self.default_options
        { version: '5' }
      end

      def initialize(path, **options)
        super
        validate_version!
      end

      def generate
        build_all_typescript_types
      end

      private

      # TypescriptMapper instance for pure type mapping logic
      def mapper
        @mapper ||= TypescriptMapper.new(introspection: @data, key_transform: key_transform)
      end

      # Collects and generates all TypeScript types:
      # - Enums
      # - Regular types
      # - Action input/output types
      def build_all_typescript_types
        all_types = []

        # Collect enum types
        enums.each do |enum_name, enum_values|
          type_name = mapper.pascal_case(enum_name)
          values_str = enum_values.sort.map { |v| "'#{v}'" }.join(' | ')
          all_types << { name: type_name, code: "export type #{type_name} = #{values_str};" }
        end

        # Collect regular types (topologically sorted to avoid forward references)
        sorted_types = TypeAnalysis.topological_sort_types(types)
        sorted_types.each do |type_name, type_shape|
          type_name_pascal = mapper.pascal_case(type_name)
          code = if type_shape.is_a?(Hash) && type_shape[:type] == :union
                   mapper.build_union_type(type_name, type_shape)
                 else
                   action_name = type_name.to_s.end_with?('_update_payload') ? 'update' : nil
                   recursive = TypeAnalysis.detect_circular_references(type_name, type_shape, filter: :custom_only)
                   mapper.build_interface(type_name, type_shape, action_name, recursive: recursive)
                 end
          all_types << { name: type_name_pascal, code: code }
        end

        # Collect action types (input/output for each action)
        each_resource do |resource_name, resource_data, parent_path|
          each_action(resource_data) do |action_name, action_data|
            if action_data[:input]&.any?
              type_name = mapper.action_type_name(resource_name, action_name, 'Input', parent_path)
              code = mapper.build_action_input_type(resource_name, action_name, action_data[:input], parent_path)
              all_types << { name: type_name, code: code }
            end

            next unless action_data[:output]

            type_name = mapper.action_type_name(resource_name, action_name, 'Output', parent_path)
            code = mapper.build_action_output_type(resource_name, action_name, action_data[:output], parent_path)
            all_types << { name: type_name, code: code }
          end
        end

        # Sort all types alphabetically by name and return
        all_types.sort_by { |t| t[:name] }.map { |t| t[:code] }.join("\n\n")
      end

      # Validate version option
      def validate_version!
        return if version.nil?

        return if VALID_VERSIONS.include?(version)

        raise ArgumentError,
              "Invalid version for typescript: #{version.inspect}. " \
              "Valid versions: #{VALID_VERSIONS.join(', ')}"
      end
    end
  end
end
