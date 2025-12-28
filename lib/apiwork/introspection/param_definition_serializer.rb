# frozen_string_literal: true

module Apiwork
  module Introspection
    class ParamDefinitionSerializer
      def initialize(param_definition, result_wrapper: nil, visited: Set.new)
        @param_definition = param_definition
        @result_wrapper = result_wrapper
        @visited = visited
        @name_resolver = NameResolver.new
      end

      def serialize
        return nil unless @param_definition

        return serialize_result_wrapped if @result_wrapper

        result = {}

        @param_definition.params.sort_by { |name, _| name.to_s }.each do |name, param_options|
          result[name] = serialize_param(name, param_options)
        end

        if @param_definition.wrapped?
          result.empty? ? nil : { type: :object, shape: result }
        else
          result.presence
        end
      end

      private

      def serialize_result_wrapped
        success_type = @result_wrapper[:success_type]
        error_type = @result_wrapper[:error_type]

        success_params = build_success_params

        success_variant = if success_type
                            register_success_type(success_type, success_params)
                            { type: success_type }
                          else
                            { type: :object, shape: success_params }
                          end

        error_variant = if error_type
                          { type: error_type }
                        else
                          { type: :object, shape: {} }
                        end

        {
          type: :union,
          variants: [success_variant, error_variant]
        }
      end

      def build_success_params
        success_params = {}
        @param_definition.params.sort_by { |name, _| name.to_s }.each do |name, param_options|
          serialized = serialize_param(name, param_options)
          serialized[:optional] = true if param_options[:optional]
          success_params[name] = serialized
        end
        success_params
      end

      def register_success_type(type_name, shape)
        api_class = @param_definition.contract_class.api_class
        return unless api_class

        type_system = api_class.type_system
        return if type_system.types.key?(type_name)

        type_system.types[type_name] = {
          scope: nil,
          expanded_payload: shape
        }
      end

      def serialize_param(name, options)
        return serialize_union_param(options) if options[:type] == :union
        return serialize_custom_type_param(options) if options[:custom_type]

        type_value = resolve_type(options[:type])

        result = {
          type: type_value,
          value: options[:type] == :literal ? options[:value] : nil,
          enum: resolve_enum(options),
          as: options[:as],
          of: resolve_of(options),
          shape: options[:shape]&.then { serialize_nested_shape(_1).presence }
        }.compact

        apply_boolean_flags(result, options)
        apply_metadata_fields(result, options)
        result[:default] = options[:default] unless options[:default].nil?

        result
      end

      def serialize_union_param(options)
        result = serialize_union(options[:union])
        apply_boolean_flags(result, options)
        apply_metadata_fields(result, options)
        result
      end

      def serialize_custom_type_param(options)
        custom_type_name = options[:custom_type]
        if @param_definition.contract_class.resolve_custom_type(custom_type_name)
          custom_type_name = @name_resolver.qualified_name(custom_type_name,
                                                           @param_definition)
        end

        result = { type: custom_type_name, as: options[:as] }.compact
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
          @name_resolver.qualified_name(type_value, @param_definition)
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
          scope = @name_resolver.scope_for_enum(@param_definition, options[:enum][:ref])
          api_class = @param_definition.contract_class.api_class
          api_class&.scoped_name(scope, options[:enum][:ref]) || options[:enum][:ref]
        else
          options[:enum]
        end
      end

      def resolve_of(options)
        return nil unless options[:of]

        if @param_definition.contract_class.resolve_custom_type(options[:of])
          @name_resolver.qualified_name(options[:of], @param_definition)
        else
          options[:of]
        end
      end

      def serialize_union(union_definition)
        result = {
          type: :union,
          variants: union_definition.variants.map { |variant| serialize_variant(variant) }
        }
        result[:discriminator] = union_definition.discriminator if union_definition.discriminator
        result
      end

      def serialize_variant(variant_definition)
        variant_type = variant_definition[:type]

        custom_type_block = @param_definition.contract_class.resolve_custom_type(variant_type)
        if custom_type_block
          qualified_variant_type = @name_resolver.qualified_name(variant_type, @param_definition)
          result = { type: qualified_variant_type }
          result[:tag] = variant_definition[:tag] if variant_definition[:tag]
          return result
        end

        result = { type: variant_type }

        result[:tag] = variant_definition[:tag] if variant_definition[:tag]

        if variant_definition[:of]
          result[:of] = if @param_definition.contract_class.resolve_custom_type(variant_definition[:of])
                          @name_resolver.qualified_name(variant_definition[:of], @param_definition)
                        else
                          variant_definition[:of]
                        end
        end

        if variant_definition[:enum]
          result[:enum] = if variant_definition[:enum].is_a?(Symbol)
                            if @param_definition.contract_class.respond_to?(:schema_class) &&
                               @param_definition.contract_class.schema_class
                              scope = @name_resolver.scope_for_enum(@param_definition, variant_definition[:enum])
                              api_class = @param_definition.contract_class.api_class
                              api_class&.scoped_name(scope, variant_definition[:enum]) || variant_definition[:enum]
                            else
                              variant_definition[:enum]
                            end
                          else
                            variant_definition[:enum]
                          end
        end

        if variant_definition[:shape]
          nested = serialize_nested_shape(variant_definition[:shape])
          result[:shape] = nested if nested.present?
        end

        result
      end

      def serialize_nested_shape(shape_definition)
        ParamDefinitionSerializer.new(shape_definition, visited: @visited).serialize
      end

      def apply_metadata_fields(result, options)
        result.merge!({
          description: resolve_attribute_description(options),
          example: options[:example],
          format: options[:format],
          min: options[:min],
          max: options[:max]
        }.compact)

        result[:deprecated] = true if options[:deprecated]
      end

      def resolve_attribute_description(options)
        return options[:description] if options[:description]

        if (attribute_definition = options[:attribute_definition])
          description = i18n_attribute_description(attribute_definition)
          return description if description
        end

        if (association_definition = options[:association_definition])
          description = i18n_association_description(association_definition)
          return description if description
        end

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
    end
  end
end
