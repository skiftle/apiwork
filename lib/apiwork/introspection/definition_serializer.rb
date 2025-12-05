# frozen_string_literal: true

module Apiwork
  module Introspection
    class DefinitionSerializer
      def initialize(definition, visited: Set.new)
        @definition = definition
        @visited = visited
        @name_resolver = NameResolver.new
      end

      def serialize
        return nil unless @definition

        return serialize_unwrapped_union if @definition.unwrapped_union?

        result = {}

        @definition.params.sort_by { |name, _| name.to_s }.each do |name, param_options|
          result[name] = serialize_param(name, param_options)
        end

        # Response bodies are always objects (unless they're unions handled above)
        if @definition.type == :response_body
          { type: :object, shape: result }
        else
          result
        end
      end

      private

      def serialize_unwrapped_union
        success_params = {}
        issue_params = {}

        @definition.params.sort_by { |name, _| name.to_s }.each do |name, param_options|
          case name
          when :issues
            issue_params[name] = serialize_param(name, param_options)
          else
            serialized = serialize_param(name, param_options)
            serialized[:optional] = true if param_options[:optional]
            success_params[name] = serialized
          end
        end

        {
          type: :union,
          variants: [
            {
              type: :object,
              shape: success_params
            },
            {
              type: :object,
              shape: issue_params
            }
          ]
        }
      end

      def serialize_param(name, options)
        if options[:type] == :union
          result = serialize_union(options[:union])
          result[:optional] = true if options[:optional]
          result[:nullable] = true if options[:nullable]
          apply_metadata_fields(result, options)
          return result
        end

        if options[:custom_type]
          custom_type_name = options[:custom_type]

          if @definition.contract_class.resolve_custom_type(custom_type_name)
            custom_type_name = @name_resolver.qualified_name(custom_type_name, @definition)
          end

          result = { type: custom_type_name }
          result[:nullable] = true if options[:nullable]
          result[:optional] = true if options[:optional]
          apply_metadata_fields(result, options)
          result[:as] = options[:as] if options[:as]
          return result
        end

        type_value = options[:type]
        if type_value && @definition.contract_class.resolve_custom_type(type_value)
          type_value = @name_resolver.qualified_name(type_value, @definition)
        elsif type_value && @definition.contract_class.resolve_enum(type_value)
          type_value = @name_resolver.qualified_name(type_value, @definition)
        end

        result = { type: type_value }
        result[:nullable] = true if options[:nullable]
        result[:optional] = true if options[:optional]
        apply_metadata_fields(result, options)

        result[:value] = options[:value] if options[:type] == :literal

        result[:default] = options[:default] unless options[:default].nil?

        if options[:enum]
          result[:enum] = if options[:enum].is_a?(Hash) && options[:enum][:ref]
                            scope = @name_resolver.scope_for_enum(@definition, options[:enum][:ref])
                            api_class = @definition.contract_class.api_class
                            api_class&.scoped_name(scope, options[:enum][:ref]) || options[:enum][:ref]
                          else
                            options[:enum]
                          end
        end

        result[:as] = options[:as] if options[:as]

        if options[:of]
          result[:of] = if @definition.contract_class.resolve_custom_type(options[:of])
                          @name_resolver.qualified_name(options[:of], @definition)
                        else
                          options[:of]
                        end
        end

        result[:shape] = serialize_nested_shape(options[:shape]) if options[:shape]

        result
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

        custom_type_block = @definition.contract_class.resolve_custom_type(variant_type)
        if custom_type_block
          qualified_variant_type = @name_resolver.qualified_name(variant_type, @definition)
          result = { type: qualified_variant_type }
          result[:tag] = variant_definition[:tag] if variant_definition[:tag]
          return result
        end

        result = { type: variant_type }

        result[:tag] = variant_definition[:tag] if variant_definition[:tag]

        if variant_definition[:of]
          result[:of] = if @definition.contract_class.resolve_custom_type(variant_definition[:of])
                          @name_resolver.qualified_name(variant_definition[:of], @definition)
                        else
                          variant_definition[:of]
                        end
        end

        if variant_definition[:enum]
          result[:enum] = if variant_definition[:enum].is_a?(Symbol)
                            if @definition.contract_class.respond_to?(:schema_class) &&
                               @definition.contract_class.schema_class
                              scope = @name_resolver.scope_for_enum(@definition, variant_definition[:enum])
                              api_class = @definition.contract_class.api_class
                              api_class&.scoped_name(scope, variant_definition[:enum]) || variant_definition[:enum]
                            else
                              variant_definition[:enum]
                            end
                          else
                            variant_definition[:enum]
                          end
        end

        result[:shape] = serialize_nested_shape(variant_definition[:shape]) if variant_definition[:shape]

        result
      end

      def serialize_nested_shape(shape_definition)
        DefinitionSerializer.new(shape_definition, visited: @visited).serialize
      end

      def apply_metadata_fields(result, options)
        description = resolve_attribute_description(options)
        result[:description] = description if description
        result[:example] = options[:example] if options[:example]
        result[:format] = options[:format] if options[:format]
        result[:deprecated] = true if options[:deprecated]
        result[:min] = options[:min] if options[:min]
        result[:max] = options[:max] if options[:max]
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
        api_class = @definition.contract_class&.api_class
        return nil unless api_class

        schema_name = attribute_definition.schema_class_name
        attribute_name = attribute_definition.name

        api_class.metadata.i18n_lookup(:schemas, schema_name, :attributes, attribute_name, :description)
      end

      def i18n_association_description(association_definition)
        api_class = @definition.contract_class&.api_class
        return nil unless api_class

        schema_name = association_definition.schema_class_name
        association_name = association_definition.name

        api_class.metadata.i18n_lookup(:schemas, schema_name, :associations, association_name, :description)
      end
    end
  end
end
