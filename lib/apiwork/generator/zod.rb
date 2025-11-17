# frozen_string_literal: true

module Apiwork
  module Generator
    class Zod < Base
      generator_name :zod
      content_type 'text/plain; charset=utf-8'

      VALID_VERSIONS = %w[3 4].freeze

      def self.file_extension
        '.ts'
      end

      def self.default_options
        { version: '4' }
      end

      def initialize(path, **options)
        super
        validate_version!
      end

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

        # Use TypeScript mapper for TypeScript types
        typescript_types = build_typescript_types
        if typescript_types.present?
          parts << typescript_types
          parts << ''
        end

        parts.join("\n")
      end

      private

      # ZodMapper instance for Zod schema generation
      def zod_mapper
        @zod_mapper ||= ZodMapper.new(introspection: @data, key_transform: key_transform)
      end

      # TypescriptMapper instance for TypeScript type generation
      def typescript_mapper
        @typescript_mapper ||= TypescriptMapper.new(introspection: @data, key_transform: key_transform)
      end

      def build_enum_schemas
        return '' if enums.empty?

        # Enum filter schemas are now auto-generated as union types in introspect[:types]
        # No need for manual generation here
        enums.map do |enum_name, enum_values|
          schema_name = zod_mapper.pascal_case(enum_name)
          values_str = enum_values.sort.map { |v| "'#{v}'" }.join(', ')
          "export const #{schema_name}Schema: z.ZodType<#{schema_name}> = z.enum([#{values_str}]);"
        end.join("\n\n")
      end

      def build_type_schemas
        # Sort ALL types in topological order to avoid forward references
        sorted_types = TypeAnalysis.topological_sort_types(types)

        # Generate schemas for all types
        schemas = sorted_types.map do |type_name, type_shape|
          if type_shape.is_a?(Hash) && type_shape[:type] == :union
            zod_mapper.build_union_schema(type_name, type_shape)
          else
            # Regular object type
            action_name = type_name.to_s.end_with?('_update_payload') ? 'update' : nil
            recursive = TypeAnalysis.circular_reference?(type_name, type_shape, filter: :custom_only)

            # Skip type annotation for discriminated union variants
            # These need inferred types for z.discriminatedUnion to work
            is_union_variant = type_name.to_s.match?(/_nested_(create|update)_payload$/)

            zod_mapper.build_object_schema(type_name, type_shape, action_name,
                                           recursive: recursive,
                                           skip_type_annotation: is_union_variant)
          end
        end

        schemas.join("\n\n")
      end

      def build_action_schemas
        schemas = []

        each_resource do |resource_name, resource_data, parent_path|
          each_action(resource_data) do |action_name, action_data|
            # Generate input schema if present
            schemas << zod_mapper.build_action_input_schema(resource_name, action_name, action_data[:input], parent_path) if action_data[:input]&.any?

            # Generate output schema if present
            schemas << zod_mapper.build_action_output_schema(resource_name, action_name, action_data[:output], parent_path) if action_data[:output]
          end
        end

        schemas.join("\n\n")
      end

      # Build all TypeScript types using TypescriptMapper
      def build_typescript_types
        all_types = []

        # Collect enum types
        enums.each do |enum_name, enum_values|
          type_name = typescript_mapper.pascal_case(enum_name)
          values_str = enum_values.sort.map { |v| "'#{v}'" }.join(' | ')
          all_types << { name: type_name, code: "export type #{type_name} = #{values_str};" }
        end

        # Collect regular types
        types.each do |type_name, type_shape|
          type_name_pascal = typescript_mapper.pascal_case(type_name)
          code = if type_shape.is_a?(Hash) && type_shape[:type] == :union
                   typescript_mapper.build_union_type(type_name, type_shape)
                 else
                   action_name = type_name.to_s.end_with?('_update_payload') ? 'update' : nil
                   recursive = TypeAnalysis.circular_reference?(type_name, type_shape, filter: :custom_only)
                   typescript_mapper.build_interface(type_name, type_shape, action_name, recursive: recursive)
                 end
          all_types << { name: type_name_pascal, code: code }
        end

        # Collect action types
        each_resource do |resource_name, resource_data, parent_path|
          each_action(resource_data) do |action_name, action_data|
            if action_data[:input]&.any?
              type_name = typescript_mapper.action_type_name(resource_name, action_name, 'Input', parent_path)
              code = typescript_mapper.build_action_input_type(resource_name, action_name, action_data[:input], parent_path)
              all_types << { name: type_name, code: code }
            end

            next unless action_data[:output]

            type_name = typescript_mapper.action_type_name(resource_name, action_name, 'Output', parent_path)
            code = typescript_mapper.build_action_output_type(resource_name, action_name, action_data[:output], parent_path)
            all_types << { name: type_name, code: code }
          end
        end

        # Sort all types alphabetically by name
        all_types.sort_by { |t| t[:name] }.map { |t| t[:code] }.join("\n\n")
      end

      # Validate version option
      def validate_version!
        return if version.nil?

        return if VALID_VERSIONS.include?(version)

        raise ArgumentError,
              "Invalid version for zod: #{version.inspect}. " \
              "Valid versions: #{VALID_VERSIONS.join(', ')}"
      end
    end
  end
end
