# frozen_string_literal: true

module Apiwork
  module Contract
    # Serialization module for converting Contract definitions to JSON
    # Used for debugging auto-generated contracts and route introspection
    module Serialization
      class << self
        def serialize_definition(definition, visited: Set.new)
          return nil unless definition

          # Check if this is an unwrapped union (special case for response outputs)
          return serialize_unwrapped_union(definition, visited: visited) if definition.unwrapped_union?

          result = {}

          sorted_params = definition.params.sort_by { |name, _| name.to_s }
          sorted_params.each do |name, param_options|
            result[name] = serialize_param(name, param_options, definition, visited: visited)
          end

          result
        end

        def serialize_unwrapped_union(definition, visited: Set.new)
          discriminator = definition.instance_variable_get(:@unwrapped_union_discriminator)

          # Separate params into success and issue variants based on typical patterns
          success_params = {}
          issue_params = {}

          definition.params.sort_by { |name, _| name.to_s }.each do |name, param_options|
            case name
            when :ok
              # ok field with literal values in each variant
              next # We'll add this manually to each variant
            when :issues
              # issues is only in issue variant
              # Issues should always be required in issue responses
              issue_params[name] = serialize_param(name, param_options, definition, visited: visited).tap do |serialized|
                serialized[:required] = true
              end
            else
              # All other fields are in success variant
              serialized = serialize_param(name, param_options, definition, visited: visited)
              # Resource fields should be required in success variant (but not meta)
              serialized[:required] = true unless name == :meta
              success_params[name] = serialized
            end
          end

          # Build union structure
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
          # Handle union types
          if options[:type] == :union
            result = serialize_union(options[:union], definition, visited: visited)
            result[:required] = options[:required] || false
            result[:nullable] = options[:nullable] || false
            apply_metadata_fields(result, options)
            return result
          end

          # Handle custom types - return type reference instead of expanding
          if options[:custom_type]
            custom_type_name = options[:custom_type]

            # Only qualify if it's actually a custom type
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

          # Qualify custom type names in 'type' parameter (only for contracts with schema_class)
          type_value = options[:type]
          type_value = qualified_type_name(type_value, definition) if type_value && definition.contract_class.resolve_custom_type(type_value)

          result = {
            type: type_value,
            required: options[:required] || false,
            nullable: options[:nullable] || false
          }
          apply_metadata_fields(result, options)

          # Add literal value for literal types
          result[:value] = options[:value] if options[:type] == :literal

          # Add optional metadata (only if meaningfully set)
          result[:default] = options[:default] if options.key?(:default) && !options[:default].nil?

          # Handle enum - differentiate between reference (hash with :ref) and inline (array)
          if options[:enum]
            if options[:enum].is_a?(Hash) && options[:enum][:ref]
              # Enum reference - output the qualified reference symbol for code generators
              # Use qualified name with correct scope for hierarchical naming
              scope = determine_scope_for_enum(definition, options[:enum][:ref])
              qualified_enum_name = Descriptor::EnumStore.scoped_name(scope, options[:enum][:ref])
              result[:enum] = qualified_enum_name
            else
              # Inline enum - output the values array
              result[:enum] = options[:enum]
            end
          end

          result[:as] = options[:as] if options[:as]

          # Handle 'of' parameter - qualify custom types (only for contracts with schema_class)
          if options[:of]
            # Check if it's a custom type that needs qualification
            result[:of] = if definition.contract_class.resolve_custom_type(options[:of])
                            qualified_type_name(options[:of], definition)
                          else
                            # Primitive type - keep as-is
                            options[:of]
                          end
          end

          # Handle shape (nested objects) - only for non-custom types
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

          # Check if variant type is a custom type - if so, just return a reference
          custom_type_block = parent_definition.contract_class.resolve_custom_type(variant_type)
          if custom_type_block
            # Custom type - return reference with qualified name
            qualified_variant_type = qualified_type_name(variant_type, parent_definition)
            result = { type: qualified_variant_type }
            result[:tag] = variant_definition[:tag] if variant_definition[:tag]
            return result
          end

          result = { type: variant_type }

          # Add tag for discriminated unions
          result[:tag] = variant_definition[:tag] if variant_definition[:tag]

          # Handle 'of' - qualify custom types but don't expand them (only for contracts with schema_class)
          if variant_definition[:of]
            # Check if it's a custom type that needs qualification
            result[:of] = if parent_definition.contract_class.resolve_custom_type(variant_definition[:of])
                            qualified_type_name(variant_definition[:of], parent_definition)
                          else
                            # Primitive type - keep as-is
                            variant_definition[:of]
                          end
          end

          # Handle enum - qualify if it's a reference (only for contracts with schema_class)
          if variant_definition[:enum]
            if variant_definition[:enum].is_a?(Symbol)
              # Enum reference - use qualified name with correct scope for hierarchical naming
              if parent_definition.contract_class.respond_to?(:schema_class) &&
                 parent_definition.contract_class.schema_class
                scope = determine_scope_for_enum(parent_definition, variant_definition[:enum])
                result[:enum] = Descriptor::EnumStore.scoped_name(scope, variant_definition[:enum])
              else
                result[:enum] = variant_definition[:enum]
              end
            else
              # Inline enum array - keep as-is
              result[:enum] = variant_definition[:enum]
            end
          end

          # Handle shape in variant (for object or array of object)
          result[:shape] = serialize_definition(variant_definition[:shape], visited: visited) if variant_definition[:shape]

          result
        end

        def scope_for_type(definition, type_name)
          definition.contract_class
        end

        def determine_scope_for_enum(definition, enum_name)
          definition.contract_class
        end

        # Check if a type is registered globally (in API storage) vs contract-scoped
        # Global types like :string_filter, :datetime_filter should NOT be qualified
        def is_global_type?(type_name, definition)
          return false unless definition.contract_class.respond_to?(:api_class)

          api_class = definition.contract_class.api_class
          return false unless api_class

          # Check if type exists in unified storage with scope: nil (unprefixed = global)
          store = Descriptor::TypeStore.send(:storage, api_class)
          metadata = store[type_name]
          return false unless metadata

          # Type is global if it has no scope (scope: nil)
          metadata[:scope].nil?
        end

        # Check if a type is imported from another contract
        # Imported types should keep their import alias, not be scoped
        def is_imported_type?(type_name, definition)
          return false unless definition.contract_class.respond_to?(:imports)

          # Use cached lookup set for fast O(1) checks instead of iterating
          import_prefixes = import_prefix_cache(definition.contract_class)

          # Direct import match (e.g., :address)
          return true if import_prefixes[:direct].include?(type_name)

          # Check for prefixed import types (e.g., :address_sort → :address import)
          type_name_str = type_name.to_s
          import_prefixes[:prefixes].any? { |prefix| type_name_str.start_with?(prefix) }
        end

        # Cache import prefixes per contract class to avoid repeated iterations
        def import_prefix_cache(contract_class)
          @import_prefix_cache ||= {}
          @import_prefix_cache[contract_class] ||= begin
            direct = Set.new(contract_class.imports.keys)
            prefixes = contract_class.imports.keys.map { |alias_name| "#{alias_name}_" }
            { direct: direct, prefixes: prefixes }
          end
        end

        # Qualifies a type name based on scope rules:
        # - Global types (scope: nil) → keep as-is
        # - Imported types → keep import alias as-is
        # - Contract-scoped types → prefix with contract name
        def qualified_type_name(type_name, definition)
          return type_name if is_global_type?(type_name, definition)
          return type_name if is_imported_type?(type_name, definition)
          return type_name unless definition.contract_class.respond_to?(:schema_class)
          return type_name unless definition.contract_class.schema_class

          scope = scope_for_type(definition, type_name)
          Descriptor::Registry.scoped_name(scope, type_name)
        end

        # Apply standard metadata fields to result hash
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
