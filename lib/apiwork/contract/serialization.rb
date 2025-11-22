# frozen_string_literal: true

module Apiwork
  module Contract
    module Serialization
      class << self
        def serialize_definition(definition, visited: Set.new)
          return nil unless definition

          return serialize_unwrapped_union(definition, visited: visited) if definition.unwrapped_union?

          result = {}

          definition.params.sort_by { |name, _| name.to_s }.each do |name, param_options|
            result[name] = serialize_param(name, param_options, definition, visited: visited)
          end

          result
        end

        def serialize_unwrapped_union(definition, visited: Set.new)
          discriminator = definition.instance_variable_get(:@unwrapped_union_discriminator)

          success_params = {}
          issue_params = {}

          definition.params.sort_by { |name, _| name.to_s }.each do |name, param_options|
            case name
            when :ok
              next # We'll add this manually to each variant
            when :issues
              issue_params[name] = serialize_param(name, param_options, definition, visited: visited).tap do |serialized|
                serialized[:required] = true
              end
            else
              serialized = serialize_param(name, param_options, definition, visited: visited)
              serialized[:required] = true unless name == :meta
              success_params[name] = serialized
            end
          end

          {
            type: :union,
            discriminator: discriminator,
            variants: [
              {
                tag: true,
                type: :object,
                shape: {
                  ok: { type: :literal, value: true, required: true },
                  **success_params
                }
              },
              {
                tag: false,
                type: :object,
                shape: {
                  ok: { type: :literal, value: false, required: true },
                  **issue_params
                }
              }
            ]
          }
        end

        def serialize_param(name, options, definition, visited: Set.new)
          if options[:type] == :union
            result = serialize_union(options[:union], definition, visited: visited)
            result[:required] = options[:required] || false
            result[:nullable] = options[:nullable] || false
            apply_metadata_fields(result, options)
            return result
          end

          if options[:custom_type]
            custom_type_name = options[:custom_type]

            custom_type_name = qualified_type_name(custom_type_name, definition) if definition.contract_class.resolve_custom_type(custom_type_name)

            result = {
              type: custom_type_name,
              required: options[:required] || false,
              nullable: options[:nullable] || false
            }
            apply_metadata_fields(result, options)
            result[:as] = options[:as] if options[:as]
            return result
          end

          type_value = options[:type]
          type_value = qualified_type_name(type_value, definition) if type_value && definition.contract_class.resolve_custom_type(type_value)

          result = {
            type: type_value,
            required: options[:required] || false,
            nullable: options[:nullable] || false
          }
          apply_metadata_fields(result, options)

          result[:value] = options[:value] if options[:type] == :literal

          result[:default] = options[:default] if options.key?(:default) && !options[:default].nil?

          if options[:enum]
            if options[:enum].is_a?(Hash) && options[:enum][:ref]
              scope = determine_scope_for_enum(definition, options[:enum][:ref])
              qualified_enum_name = Descriptor.scoped_enum_name(scope, options[:enum][:ref])
              result[:enum] = qualified_enum_name
            else
              result[:enum] = options[:enum]
            end
          end

          result[:as] = options[:as] if options[:as]

          if options[:of]
            result[:of] = if definition.contract_class.resolve_custom_type(options[:of])
                            qualified_type_name(options[:of], definition)
                          else
                            options[:of]
                          end
          end

          result[:shape] = serialize_definition(options[:shape], visited: visited) if options[:shape]

          result
        end

        def serialize_union(union_definition, definition, visited: Set.new)
          result = {
            type: :union,
            variants: union_definition.variants.map { |variant| serialize_variant(variant, definition, visited: visited) }
          }
          result[:discriminator] = union_definition.discriminator if union_definition.discriminator
          result
        end

        def serialize_variant(variant_definition, parent_definition, visited: Set.new)
          variant_type = variant_definition[:type]

          custom_type_block = parent_definition.contract_class.resolve_custom_type(variant_type)
          if custom_type_block
            qualified_variant_type = qualified_type_name(variant_type, parent_definition)
            result = { type: qualified_variant_type }
            result[:tag] = variant_definition[:tag] if variant_definition[:tag]
            return result
          end

          result = { type: variant_type }

          result[:tag] = variant_definition[:tag] if variant_definition[:tag]

          if variant_definition[:of]
            result[:of] = if parent_definition.contract_class.resolve_custom_type(variant_definition[:of])
                            qualified_type_name(variant_definition[:of], parent_definition)
                          else
                            variant_definition[:of]
                          end
          end

          if variant_definition[:enum]
            if variant_definition[:enum].is_a?(Symbol)
              if parent_definition.contract_class.respond_to?(:schema_class) &&
                 parent_definition.contract_class.schema_class
                scope = determine_scope_for_enum(parent_definition, variant_definition[:enum])
                result[:enum] = Descriptor.scoped_enum_name(scope, variant_definition[:enum])
              else
                result[:enum] = variant_definition[:enum]
              end
            else
              result[:enum] = variant_definition[:enum]
            end
          end

          result[:shape] = serialize_definition(variant_definition[:shape], visited: visited) if variant_definition[:shape]

          result
        end

        def scope_for_type(definition)
          definition.contract_class
        end

        def determine_scope_for_enum(definition, enum_name)
          definition.contract_class
        end

        def is_global_type?(type_name, definition)
          return false unless definition.contract_class.respond_to?(:api_class)

          api_class = definition.contract_class.api_class
          return false unless api_class

          Descriptor.type_global?(type_name, api_class: api_class)
        end

        def is_imported_type?(type_name, definition)
          return false unless definition.contract_class.respond_to?(:imports)

          import_prefixes = import_prefix_cache(definition.contract_class)

          return true if import_prefixes[:direct].include?(type_name)

          type_name_str = type_name.to_s
          import_prefixes[:prefixes].any? { |prefix| type_name_str.start_with?(prefix) }
        end

        def import_prefix_cache(contract_class)
          @import_prefix_cache ||= {}
          @import_prefix_cache[contract_class] ||= begin
            direct = Set.new(contract_class.imports.keys)
            { direct: direct, prefixes: contract_class.imports.keys.map { |alias_name| "#{alias_name}_" } }
          end
        end

        def qualified_type_name(type_name, definition)
          return type_name if is_global_type?(type_name, definition)
          return type_name if is_imported_type?(type_name, definition)
          return type_name unless definition.contract_class.respond_to?(:schema_class)
          return type_name unless definition.contract_class.schema_class

          scope = scope_for_type(definition)
          Descriptor.scoped_type_name(scope, type_name)
        end

        def apply_metadata_fields(result, options)
          result[:description] = options[:description]
          result[:example] = options[:example]
          result[:format] = options[:format]
          result[:deprecated] = options[:deprecated] || false
          result[:min] = options[:min]
          result[:max] = options[:max]
        end
      end
    end
  end
end
