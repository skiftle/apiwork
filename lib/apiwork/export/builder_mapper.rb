# frozen_string_literal: true

module Apiwork
  module Export
    class BuilderMapper
      class << self
        def map(export, surface)
          new(export).map(surface)
        end
      end

      def initialize(export)
        @export = export
      end

      def map(surface)
        build_builders(surface.types)
      end

      def build_builders(types)
        builders = types.sort_by { |name, _type| name.to_s }.flat_map do |name, type|
          if type.union?
            build_union_builders(name, type, types)
          elsif type.object?
            [build_object_builder(name, type)]
          end
        end.compact

        builders.join("\n\n")
      end

      private

      def build_object_builder(name, type)
        type_name = pascal_case(name)
        defaulted, required = classify_fields(type.shape)

        if defaulted.empty?
          build_required_only_builder(type_name, required)
        elsif required.empty?
          build_all_defaulted_builder(type_name, defaulted)
        else
          build_mixed_builder(type_name, defaulted, required)
        end
      end

      def build_required_only_builder(type_name, required)
        assignments = build_assignments_body(required, defaulted: {})

        "export function build#{type_name}(fields: #{type_name}): #{type_name} {\n" \
          "  return {\n" \
          "#{assignments}\n" \
          "  };\n" \
          '}'
      end

      def build_all_defaulted_builder(type_name, defaulted)
        assignments = build_assignments_body(defaulted, optional_fields: true)

        "export function build#{type_name}(fields?: Partial<#{type_name}>): #{type_name} {\n" \
          "  return {\n" \
          "#{assignments}\n" \
          "  };\n" \
          '}'
      end

      def build_mixed_builder(type_name, defaulted, required)
        required_keys = required.keys.map { |name| "'#{@export.transform_key(name)}'" }.sort.join(' | ')
        fields_type = "Pick<#{type_name}, #{required_keys}> & Partial<#{type_name}>"
        assignments = build_assignments_body(defaulted.merge(required), defaulted:)

        "export function build#{type_name}(fields: #{fields_type}): #{type_name} {\n" \
          "  return {\n" \
          "#{assignments}\n" \
          "  };\n" \
          '}'
      end

      def build_assignments_body(fields, defaulted: fields, optional_fields: false)
        accessor = optional_fields ? 'fields?.' : 'fields.'
        fields.sort_by { |name, _param| name.to_s }.map do |name, param|
          key = @export.transform_key(name)
          if defaulted.key?(name)
            "    #{key}: #{accessor}#{key} !== undefined ? #{accessor}#{key} : #{serialize_default(param)},"
          else
            "    #{key}: #{accessor}#{key},"
          end
        end.join("\n")
      end

      def build_union_builders(name, type, types)
        type_name = pascal_case(name)
        builders = []

        return builders unless type.discriminator

        type.variants.each do |variant|
          next unless variant.tag
          next if variant.reference? && types.key?(variant.reference)

          builders << build_variant_builder(type_name, type.discriminator, variant)
        end

        builders
      end

      def build_variant_builder(type_name, discriminator, variant)
        discriminator_key = @export.transform_key(discriminator)
        builder_name = variant.reference? ? "build#{pascal_case(variant.reference)}" : "build#{type_name}#{pascal_case(variant.tag)}"
        extract_type = "Extract<#{type_name}, { #{discriminator_key}: '#{variant.tag}' }>"

        variant_defaults = {}
        variant_required = {}

        variant_defaults, variant_required = classify_fields(variant.shape) if variant.object? && variant.shape.any?

        fields_type = build_variant_fields_type(extract_type, discriminator_key, variant_defaults, variant_required)

        all_variant_fields = variant_defaults.merge(variant_required)
        body_lines = ["    #{discriminator_key}: '#{variant.tag}',"]
        all_variant_fields.sort_by { |name, _param| name.to_s }.each do |name, param|
          key = @export.transform_key(name)
          body_lines << if variant_defaults.key?(name)
                          "    #{key}: fields.#{key} !== undefined ? fields.#{key} : #{serialize_default(param)},"
                        else
                          "    #{key}: fields.#{key},"
                        end
        end

        "export function #{builder_name}(fields: #{fields_type}): #{type_name} {\n" \
          "  return {\n" \
          "#{body_lines.join("\n")}\n" \
          "  };\n" \
          '}'
      end

      def build_variant_fields_type(extract_type, discriminator_key, defaulted, required)
        omitted_type = "Omit<#{extract_type}, '#{discriminator_key}'>"

        if required.empty? && defaulted.empty?
          omitted_type
        elsif required.empty?
          "Partial<#{omitted_type}>"
        else
          required_keys = required.keys.map { |name| "'#{@export.transform_key(name)}'" }.sort.join(' | ')
          "Pick<#{omitted_type}, #{required_keys}> & Partial<#{omitted_type}>"
        end
      end

      def classify_fields(shape)
        defaulted = {}
        required = {}

        shape.sort_by { |name, _param| name.to_s }.each do |name, param|
          if defaulted_field?(param)
            defaulted[name] = param
          else
            required[name] = param
          end
        end

        [defaulted, required]
      end

      def defaulted_field?(param)
        return true if param.nullable?
        return true if param.respond_to?(:default) && !param.default.nil?

        false
      end

      def serialize_default(param)
        if param.respond_to?(:default) && !param.default.nil?
          serialize_value(param.default)
        elsif param.nullable?
          'null'
        end
      end

      def serialize_value(value)
        case value
        when String then "'#{value.gsub("'", "\\\\'")}'"
        when Integer, Float then value.to_s
        when BigDecimal then value.to_s('F')
        when TrueClass, FalseClass then value.to_s
        when Array then '[]'
        when Hash then '{}'
        else value.to_s
        end
      end

      def pascal_case(name)
        name.to_s.camelize(:upper)
      end
    end
  end
end
