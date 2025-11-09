# frozen_string_literal: true

module Apiwork
  module Generation
    class Zod < Base
      generator_name :zod
      content_type 'text/plain; charset=utf-8'

      def self.file_extension
        '.ts'
      end

      class << self
        # Generate schemas only (without document wrapper) from schema metadata
        # Used by Transport to build custom TypeScript documents
        def generate_schemas_only(schemas, key_transform: :camelize_lower)
          instance = new(nil, key_transform: key_transform)
          schemas.map { |schema| instance.send(:generate_schemas, schema, key_transform) }
        end

        # Build common query schemas - used by Transport
        def build_common_schemas(key_transform)
          new(nil, key_transform: key_transform).send(:build_common_schemas, key_transform)
        end
      end

      def initialize(path, key_transform: :camelize_lower, **options)
        @path = path
        @key_transform = key_transform
        @options = options

        # Only load schemas if path is provided
        @schemas = path ? API::Inspector.resources(path: path) : []
      end

      def generate
        schemas = @schemas.map { |schema| generate_schemas(schema, @key_transform) }
        build_typescript_document(schemas, @path, @key_transform)
      end

      private

      # Map DB type to Zod type
      TYPE_MAP = {
        'string' => 'z.string()',
        'text' => 'z.string()',
        'uuid' => 'z.string().uuid()',
        'integer' => 'z.number().int()',
        'float' => 'z.number()',
        'decimal' => 'z.number()',
        'boolean' => 'z.boolean()',
        'date' => 'z.string().date()',
        'datetime' => 'z.string().datetime()',
        'json' => 'z.record(z.string(), z.any())',
        'jsonb' => 'z.record(z.string(), z.any())'
      }.freeze

      # Build complete TypeScript document
      def build_typescript_document(schemas, namespaces, key_transform)
        parts = []

        # 1. Imports
        parts << "import { z } from 'zod';\n"

        # 2. Common query schemas
        parts << '// Common query schemas'
        parts << build_common_schemas(key_transform)
        parts << ''

        # 3. Enum schemas
        enum_defs = collect_and_format_enum_schemas(schemas, namespaces, key_transform)
        unless enum_defs.empty?
          parts << '// Enum schemas'
          parts << enum_defs
          parts << ''
        end

        # 4. Resource schemas
        parts << '// Resource schemas'
        parts << schemas.map { |s| format_resource_schemas(s) }.join("\n\n")

        parts.join("\n")
      end

      # Format all schemas for a resource
      def format_resource_schemas(schema)
        name = schema[:name].camelize

        [
          schema[:schema],
          '',
          schema[:create_payload_schema],
          '',
          schema[:update_payload_schema],
          '',
          schema[:query_schema],
          '',
          "export type #{name} = z.infer<typeof #{name}Schema>;",
          "export type #{name}CreatePayload = z.infer<typeof #{name}CreatePayloadSchema>;",
          "export type #{name}UpdatePayload = z.infer<typeof #{name}UpdatePayloadSchema>;",
          "export type #{name}Query = z.infer<typeof #{name}QuerySchema>;"
        ].join("\n")
      end

      # Build common query operator schemas
      def build_common_schemas(key_transform)
        <<~TYPESCRIPT.strip
          export const SortDirectionSchema = z.enum(['asc', 'desc']);

          export const StringFilterSchema = z.union([
            z.string(),
            z.object({
              #{transform_operator_keys('eq', key_transform)}: z.string().optional(),
              #{transform_operator_keys('contains', key_transform)}: z.string().optional(),
              #{transform_operator_keys('starts_with', key_transform)}: z.string().optional(),
              #{transform_operator_keys('ends_with', key_transform)}: z.string().optional(),
              in: z.array(z.string()).optional()
            })
          ]);

          export const NumberFilterSchema = z.union([
            z.number(),
            z.string(),
            z.null(),
            z.object({
              #{transform_operator_keys('eq', key_transform)}: z.number().optional(),
              #{transform_operator_keys('gt', key_transform)}: z.number().optional(),
              #{transform_operator_keys('gte', key_transform)}: z.number().optional(),
              #{transform_operator_keys('lt', key_transform)}: z.number().optional(),
              #{transform_operator_keys('lte', key_transform)}: z.number().optional(),
              #{transform_operator_keys('between', key_transform)}: z.tuple([z.number(), z.number()]).optional(),
              in: z.array(z.number()).optional()
            })
          ]);

          export const DateFilterSchema = z.union([
            z.string().nullable(),
            z.object({
              #{transform_operator_keys('eq', key_transform)}: z.string().nullable().optional(),
              #{transform_operator_keys('gt', key_transform)}: z.string().optional(),
              #{transform_operator_keys('gte', key_transform)}: z.string().optional(),
              #{transform_operator_keys('lt', key_transform)}: z.string().optional(),
              #{transform_operator_keys('lte', key_transform)}: z.string().optional(),
              #{transform_operator_keys('between', key_transform)}: z.tuple([z.string(), z.string()]).optional(),
              in: z.array(z.string()).optional()
            })
          ]);

          export const UuidFilterSchema = z.union([
            z.string().uuid(),
            z.array(z.string().uuid()),
            z.object({
              #{transform_operator_keys('eq', key_transform)}: z.string().uuid().optional(),
              in: z.array(z.string().uuid()).optional()
            })
          ]);

          export const BooleanFilterSchema = z.union([
            z.boolean(),
            z.enum(['true', 'false', '1', '0']),
            z.number().int().min(0).max(1),
            z.null(),
            z.object({
              #{transform_operator_keys('eq', key_transform)}: z.boolean().optional()
            })
          ]);

          export const PaginationSchema = z.object({
            #{transform_key('number', key_transform)}: z.number().int().optional(),
            #{transform_key('size', key_transform)}: z.number().int().optional()
          });
        TYPESCRIPT
      end

      # Collect and format enum schemas from all resources
      def collect_and_format_enum_schemas(schemas, namespaces, key_transform)
        enums = {}

        schemas.each do |schema|
          # Use schema attributes directly (already populated by Inspector)
          attributes = schema[:attributes] || {}

          attributes.each do |attribute_name, attribute_info|
            next unless attribute_info[:enum]

            enum_name = "#{schema[:name].camelize}#{attribute_name.to_s.camelize}"
            enums[enum_name] = {
              values: attribute_info[:enum],
              resource_name: schema[:name],
              attribute_name: attribute_name
            }
          end
        end

        enum_schemas = enums.map do |name, info|
          values_str = info[:values].map { |v| "'#{v}'" }.join(', ')
          "export const #{name}Schema = z.enum([#{values_str}]);"
        end.join("\n")

        enum_filter_schemas = enums.map do |name, _info|
          <<~TYPESCRIPT.strip
            export const #{name}FilterSchema = z.union([
              #{name}Schema,
              z.object({
                #{transform_operator_keys('eq', key_transform)}: #{name}Schema.optional(),
                in: z.array(#{name}Schema).optional()
              })
            ]);
          TYPESCRIPT
        end.join("\n")

        [enum_schemas, enum_filter_schemas].reject(&:empty?).join("\n\n")
      end

      def generate_schemas(schema, key_transform)
        result = {
          name: schema[:name],
          namespaces: schema[:namespaces],
          type: schema[:type],
          root_key: schema[:root_key],
          schema_class: schema[:schema_class],
          schema: build_full_schema(schema, key_transform),
          create_payload_schema: build_create_payload_schema(schema, key_transform),
          update_payload_schema: build_update_payload_schema(schema, key_transform),
          query_schema: build_query_schema(schema, key_transform)
        }

        # Preserve action_schemas if they exist
        result[:action_schemas] = schema[:action_schemas] if schema[:action_schemas]

        result
      end

      # Full serialization schema (all attributes + associations)
      def build_full_schema(resource, key_transform)
        resource_name = resource[:name].camelize

        attributes = resource[:attributes].map do |name, info|
          key = transform_key(name, key_transform)
          type = map_type(info, resource_name: resource[:name], attribute_name: name)
          "  #{key}: #{type}"
        end

        associations = resource[:associations].map do |name, info|
          key = transform_key(name, key_transform)
          type = association_type(info)
          "  #{key}: #{type}"
        end

        all_fields = (attributes + associations).join(",\n")

        "export const #{resource_name}Schema = z.object({\n#{all_fields}\n});"
      end

      # Create payload schema - includes writable on :create
      def build_create_payload_schema(resource, key_transform)
        resource_name = resource[:name].camelize

        # Include attributes writable on :create
        attributes = resource[:attributes].select do |_name, info|
          writable_config = info[:writable]
          writable_config.is_a?(Hash) && writable_config[:on].include?(:create)
        end.map do |name, info|
          key = transform_key(name, key_transform)
          type = map_payload_type(info, resource[:name], name, for_create: true)
          "  #{key}: #{type}"
        end

        # Include writable associations
        associations = resource[:associations].select do |_name, info|
          writable_config = info[:writable]
          writable_config.is_a?(Hash) && writable_config[:on].any?
        end.map do |name, info|
          key = transform_key(name, key_transform)
          type = association_create_payload_type(info)
          "  #{key}: #{type}"
        end

        all_fields = (attributes + associations).join(",\n")

        return "export const #{resource_name}CreatePayloadSchema = z.object({});" if all_fields.empty?

        "export const #{resource_name}CreatePayloadSchema = z.object({\n#{all_fields}\n});"
      end

      # Update payload schema - includes writable on :update (ALL OPTIONAL)
      def build_update_payload_schema(resource, key_transform)
        resource_name = resource[:name].camelize

        # Include attributes writable on :update
        attributes = resource[:attributes].select do |_name, info|
          writable_config = info[:writable]
          writable_config.is_a?(Hash) && writable_config[:on].include?(:update)
        end.map do |name, info|
          key = transform_key(name, key_transform)
          type = map_payload_type(info, resource[:name], name, for_create: false)
          "  #{key}: #{type}"
        end

        # Include writable associations
        associations = resource[:associations].select do |_name, info|
          writable_config = info[:writable]
          writable_config.is_a?(Hash) && writable_config[:on].any?
        end.map do |name, info|
          key = transform_key(name, key_transform)
          type = association_update_payload_type(info)
          "  #{key}: #{type}"
        end

        all_fields = (attributes + associations).join(",\n")

        return "export const #{resource_name}UpdatePayloadSchema = z.object({});" if all_fields.empty?

        "export const #{resource_name}UpdatePayloadSchema = z.object({\n#{all_fields}\n});"
      end

      # Query parameters schema (filter, sort, page)
      def build_query_schema(resource, key_transform)
        resource_name = resource[:name].camelize

        filterable_attributes = resource[:attributes].select { |_name, info| info[:filterable] }
        sortable_attributes = resource[:attributes].select { |_name, info| info[:sortable] }

        filter_schema = build_filter_schema(filterable_attributes, resource, key_transform)
        sort_schema = build_sort_schema(sortable_attributes, key_transform)

        filter_key = transform_key('filter', key_transform)
        sort_key = transform_key('sort', key_transform)
        page_key = transform_key('page', key_transform)

        <<~TYPESCRIPT.strip
          export const #{resource_name}QuerySchema = z.object({
            #{filter_key}: #{filter_schema}.optional(),
            #{sort_key}: #{sort_schema}.optional(),
            #{page_key}: PaginationSchema.optional()
          });
        TYPESCRIPT
      end

      def build_filter_schema(filterable_attributes, resource, key_transform)
        return 'z.object({})' if filterable_attributes.empty?

        filters = filterable_attributes.map do |name, info|
          key = transform_key(name, key_transform)
          operators = filter_operators_for_type(info[:type], info[:enum], resource[:name], name)
          "    #{key}: #{operators}.optional()"
        end.join(",\n")

        "z.object({\n#{filters}\n  })"
      end

      def build_sort_schema(sortable_attributes, key_transform)
        return 'z.object({})' if sortable_attributes.empty?

        sorts = sortable_attributes.map do |name, _info|
          key = transform_key(name, key_transform)
          "    #{key}: SortDirectionSchema.optional()"
        end.join(",\n")

        "z.object({\n#{sorts}\n  })"
      end

      # Return schema reference name instead of inline definition
      def filter_operators_for_type(type, is_enum, resource_name, attribute_name)
        if is_enum
          enum_schema_name = "#{resource_name.camelize}#{attribute_name.to_s.camelize}"
          "#{enum_schema_name}FilterSchema"
        else
          case type
          when 'string', 'text'
            'StringFilterSchema'
          when 'integer', 'float', 'decimal'
            'NumberFilterSchema'
          when 'date', 'datetime'
            'DateFilterSchema'
          when 'uuid'
            'UuidFilterSchema'
          when 'boolean'
            'BooleanFilterSchema'
          else
            'StringFilterSchema'
          end
        end
      end

      # Map attribute to Zod type, using enum schema references
      def map_type(attribute_info, resource_name:, attribute_name:)
        base = TYPE_MAP[attribute_info[:type]] || 'z.string()'

        # Use enum schema reference
        if attribute_info[:enum]
          enum_schema_name = "#{resource_name.camelize}#{attribute_name.to_s.camelize}"
          base = "#{enum_schema_name}Schema"
        end

        # Nullable (respect null_to_empty for strings)
        base += '.nullable()' if attribute_info[:nullable] && !attribute_info[:null_to_empty]

        base
      end

      # Map payload attribute type with required handling
      def map_payload_type(attribute_info, resource_name, attribute_name, for_create:)
        base = TYPE_MAP[attribute_info[:type]] || 'z.string()'

        # Use enum schema reference
        if attribute_info[:enum]
          enum_schema_name = "#{resource_name.camelize}#{attribute_name.to_s.camelize}"
          base = "#{enum_schema_name}Schema"
        end

        # Handle nullable
        base += '.nullable()' if attribute_info[:nullable] && !attribute_info[:null_to_empty]

        # For create: use required flag
        # For update: ALWAYS optional (Rails PATCH standard)
        if for_create
          base += '.optional()' unless attribute_info[:required]
        else
          base += '.optional()' unless base.end_with?('.optional()')
        end

        base
      end

      def association_type(assoc_info)
        # Try to get name from multiple sources
        target_name = if assoc_info[:name]
                        assoc_info[:name].camelize
                      elsif assoc_info[:schema_class_name]
                        # Extract "Address" from "Api::V1::AddressSchema"
                        assoc_info[:schema_class_name].demodulize.sub(/Schema$/, '')
                      else
                        'Unknown'
                      end

        schema_ref = "#{target_name}Schema"

        # Smart logic for serializable associations:
        # serializable: true → always included - use nullable from DB/config
        # serializable: false → optional (only via includes)
        serializable = assoc_info[:serializable]
        kind = assoc_info[:kind]
        nullable = assoc_info[:nullable]

        # Build base type with nullability
        type = case kind
               when 'has_one', 'belongs_to'
                 # Add nullable if association can be null in DB
                 nullable ? "#{schema_ref}.nullable()" : schema_ref
               when 'has_many'
                 "z.array(#{schema_ref})"
               else
                 schema_ref
               end

        # For non-serializable associations: make them optional (field may not be present)
        unless serializable
          # If nullable, keep it and add .optional()
          # If not nullable but not serializable, make optional without nullable
          if nullable
            # Already has .nullable(), just add .optional()
            type += '.optional()'
          else
            # Not nullable but not serializable → make optional without nullable
            type = case kind
                   when 'has_many'
                     "z.array(#{schema_ref}).optional()"
                   else
                     "#{schema_ref}.optional()"
                   end
          end
        end

        type
      end

      def association_create_payload_type(assoc_info)
        # Try to get name from multiple sources
        target_name = if assoc_info[:name]
                        assoc_info[:name].camelize
                      elsif assoc_info[:schema_class_name]
                        assoc_info[:schema_class_name].demodulize.sub(/Schema$/, '')
                      else
                        'Unknown'
                      end

        schema_ref = "#{target_name}CreatePayloadSchema"

        case assoc_info[:kind]
        when 'has_one', 'belongs_to'
          "#{schema_ref}.optional()"
        when 'has_many'
          "z.array(#{schema_ref}).optional()"
        else
          "#{schema_ref}.optional()"
        end
      end

      def association_update_payload_type(assoc_info)
        # Try to get name from multiple sources
        target_name = if assoc_info[:name]
                        assoc_info[:name].camelize
                      elsif assoc_info[:schema_class_name]
                        assoc_info[:schema_class_name].demodulize.sub(/Schema$/, '')
                      else
                        'Unknown'
                      end

        schema_ref = "#{target_name}UpdatePayloadSchema"

        case assoc_info[:kind]
        when 'has_one', 'belongs_to'
          "#{schema_ref}.optional()"
        when 'has_many'
          "z.array(#{schema_ref}).optional()"
        else
          "#{schema_ref}.optional()"
        end
      end

      # Alias for consistency with other parts of codebase
      def transform_operator_keys(operator, strategy)
        transform_key(operator, strategy)
      end
    end
  end
end
