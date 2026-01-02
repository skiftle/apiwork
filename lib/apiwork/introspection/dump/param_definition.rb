# frozen_string_literal: true

module Apiwork
  module Introspection
    module Dump
      class ParamDefinition
        def initialize(param_definition, result_wrapper: nil, visited: Set.new)
          @param_definition = param_definition
          @result_wrapper = result_wrapper
          @visited = visited
          @import_prefix_cache = {}
        end

        def to_h
          return nil unless @param_definition

          return dump_result_wrapped if @result_wrapper

          result = {}

          @param_definition.params.sort_by { |name, _| name.to_s }.each do |name, param_options|
            result[name] = dump_param(name, param_options)
          end

          if @param_definition.wrapped?
            { shape: result, type: :object }
          else
            result
          end
        end

        private

        def dump_result_wrapped
          success_type = @result_wrapper[:success_type]
          error_type = @result_wrapper[:error_type]

          success_params = build_success_params

          success_variant = if success_type
                              register_success_type(success_type, success_params)
                              { type: success_type }
                            else
                              { shape: success_params, type: :object }
                            end

          error_variant = if error_type
                            { type: error_type }
                          else
                            { shape: {}, type: :object }
                          end

          {
            type: :union,
            variants: [success_variant, error_variant],
          }
        end

        def build_success_params
          success_params = {}
          @param_definition.params.sort_by { |name, _| name.to_s }.each do |name, param_options|
            dumped = dump_param(name, param_options)
            dumped[:optional] = true if param_options[:optional]
            success_params[name] = dumped
          end
          success_params
        end

        def register_success_type(type_name, shape)
          api_class = @param_definition.contract_class.api_class
          return unless api_class

          type_system = api_class.type_system
          return if type_system.types.key?(type_name)

          type_system.types[type_name] = {
            expanded_payload: shape,
            scope: nil,
          }
        end

        def dump_param(name, options)
          return dump_union_param(options) if options[:type] == :union
          return dump_custom_type_param(options) if options[:custom_type]

          type_value = resolve_type(options[:type])

          result = {
            as: options[:as],
            enum: resolve_enum(options),
            of: resolve_of(options),
            shape: options[:shape]&.then { dump_nested_shape(_1) },
            type: type_value,
            value: options[:type] == :literal ? options[:value] : nil,
          }

          apply_boolean_flags(result, options)
          apply_metadata_fields(result, options)
          result[:default] = options[:default] unless options[:default].nil?

          result
        end

        def dump_union_param(options)
          result = dump_union(options[:union])
          apply_boolean_flags(result, options)
          apply_metadata_fields(result, options)
          result
        end

        def dump_custom_type_param(options)
          custom_type_name = options[:custom_type]
          if @param_definition.contract_class.resolve_custom_type(custom_type_name)
            custom_type_name = qualified_name(
              custom_type_name,
              @param_definition,
            )
          end

          result = { as: options[:as], type: custom_type_name }
          apply_boolean_flags(result, options)
          apply_metadata_fields(result, options)
          result
        end

        def apply_boolean_flags(result, options)
          result[:nullable] = true if options[:nullable]
          result[:optional] = true if options[:optional]
        end

        def resolve_type(type_value)
          return type_value unless type_value

          if registered_type?(type_value)
            qualified_name(type_value, @param_definition)
          else
            type_value
          end
        end

        def registered_type?(type_value)
          return false unless type_value.is_a?(Symbol)

          contract_class = @param_definition.contract_class
          return true if contract_class.resolve_custom_type(type_value)
          return true if contract_class.resolve_enum(type_value)

          api_class = contract_class.api_class
          return false unless api_class

          scoped_name = api_class.scoped_name(contract_class, type_value)
          api_class.type_system.types.key?(scoped_name) || api_class.type_system.types.key?(type_value)
        end

        def resolve_enum(options)
          return nil unless options[:enum]

          if options[:enum].is_a?(Hash) && options[:enum][:ref]
            scope = scope_for_enum(@param_definition, options[:enum][:ref])
            api_class = @param_definition.contract_class.api_class
            api_class&.scoped_name(scope, options[:enum][:ref]) || options[:enum][:ref]
          else
            options[:enum]
          end
        end

        def resolve_of(options)
          return nil unless options[:of]

          if @param_definition.contract_class.resolve_custom_type(options[:of])
            qualified_name(options[:of], @param_definition)
          else
            options[:of]
          end
        end

        def dump_union(union_definition)
          result = {
            type: :union,
            variants: union_definition.variants.map { |variant| dump_variant(variant) },
          }
          result[:discriminator] = union_definition.discriminator if union_definition.discriminator
          result
        end

        def dump_variant(variant_definition)
          variant_type = variant_definition[:type]

          custom_type_block = @param_definition.contract_class.resolve_custom_type(variant_type)
          if custom_type_block
            qualified_variant_type = qualified_name(variant_type, @param_definition)
            result = { type: qualified_variant_type }
            result[:tag] = variant_definition[:tag] if variant_definition[:tag]
            return result
          end

          result = { type: variant_type }

          result[:tag] = variant_definition[:tag] if variant_definition[:tag]

          if variant_definition[:of]
            result[:of] = if @param_definition.contract_class.resolve_custom_type(variant_definition[:of])
                            qualified_name(variant_definition[:of], @param_definition)
                          else
                            variant_definition[:of]
                          end
          end

          if variant_definition[:enum]
            result[:enum] = if variant_definition[:enum].is_a?(Symbol)
                              if @param_definition.contract_class.respond_to?(:schema_class) &&
                                 @param_definition.contract_class.schema_class
                                scope = scope_for_enum(@param_definition, variant_definition[:enum])
                                api_class = @param_definition.contract_class.api_class
                                api_class&.scoped_name(scope, variant_definition[:enum]) || variant_definition[:enum]
                              else
                                variant_definition[:enum]
                              end
                            else
                              variant_definition[:enum]
                            end
          end

          result[:shape] = dump_nested_shape(variant_definition[:shape]) if variant_definition[:shape]

          result
        end

        def dump_nested_shape(shape_definition)
          ParamDefinition.new(shape_definition, visited: @visited).to_h
        end

        def apply_metadata_fields(result, options)
          result[:description] = resolve_attribute_description(options)
          result[:example] = options[:example]
          result[:format] = options[:format]
          result[:max] = options[:max]
          result[:min] = options[:min]
          result[:deprecated] = true if options[:deprecated]
        end

        def resolve_attribute_description(options)
          return options[:description] if options[:description]

          param_name = options[:name]
          return nil unless param_name

          schema_class = resolve_schema_class
          return nil unless schema_class

          if (attribute_definition = schema_class.attribute_definitions[param_name])
            description = i18n_attribute_description(attribute_definition)
            return description if description
          end

          if (association_definition = schema_class.association_definitions[param_name])
            description = i18n_association_description(association_definition)
            return description if description
          end

          nil
        end

        def resolve_schema_class
          contract_class = @param_definition.contract_class
          return contract_class.schema_class if contract_class.respond_to?(:schema_class) && contract_class.schema_class

          nil
        end

        def i18n_attribute_description(attribute_definition)
          api_class = @param_definition.contract_class.api_class
          return nil unless api_class

          schema_name = attribute_definition.schema_class_name
          attribute_name = attribute_definition.name

          api_class.structure.i18n_lookup(:schemas, schema_name, :attributes, attribute_name, :description)
        end

        def i18n_association_description(association_definition)
          api_class = @param_definition.contract_class.api_class
          return nil unless api_class

          schema_name = association_definition.schema_class_name
          association_name = association_definition.name

          api_class.structure.i18n_lookup(:schemas, schema_name, :associations, association_name, :description)
        end

        def scope_for_enum(definition, _enum_name)
          definition.contract_class
        end

        def qualified_name(type_name, definition)
          return type_name if global_type?(type_name, definition)
          return type_name if global_enum?(type_name, definition)
          return type_name if imported_type?(type_name, definition)

          scope = definition.contract_class
          api_class = definition.contract_class.api_class
          api_class&.scoped_name(scope, type_name) || type_name
        end

        def global_type?(type_name, definition)
          return false unless definition.contract_class.respond_to?(:api_class)

          api_class = definition.contract_class.api_class
          return false unless api_class

          metadata = api_class.type_system.type_metadata(type_name)
          return false unless metadata

          metadata[:scope].nil?
        end

        def global_enum?(enum_name, definition)
          return false unless definition.contract_class.respond_to?(:api_class)

          api_class = definition.contract_class.api_class
          return false unless api_class

          metadata = api_class.type_system.enum_metadata(enum_name)
          return false unless metadata

          metadata[:scope].nil?
        end

        def imported_type?(type_name, definition)
          return false unless definition.contract_class.respond_to?(:imports)

          import_prefixes = import_prefix_cache(definition.contract_class)

          return true if import_prefixes[:direct].include?(type_name)

          type_name = type_name.to_s
          import_prefixes[:prefixes].any? { |prefix| type_name.start_with?(prefix) }
        end

        def import_prefix_cache(contract_class)
          @import_prefix_cache[contract_class] ||= begin
            direct = Set.new(contract_class.imports.keys)
            { direct:, prefixes: contract_class.imports.keys.map { |alias_name| "#{alias_name}_" } }
          end
        end
      end
    end
  end
end
