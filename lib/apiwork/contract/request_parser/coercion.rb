# frozen_string_literal: true

module Apiwork
  module Contract
    class RequestParser
      module Coercion
        module_function

        def coerce_hash(hash, definition)
          coerced = hash.dup

          definition.params.each do |name, param_options|
            next unless coerced.key?(name)

            coerced[name] = coerce_value(coerced[name], param_options, definition)
          end

          coerced
        end

        def coerce_value(value, param_options, definition)
          type = param_options[:type]

          return coerce_union(value, param_options[:union], definition) if type == :union
          return coerce_array(value, param_options, definition) if type == :array && value.is_a?(Array)
          return coerce_hash(value, param_options[:shape]) if param_options[:shape] && value.is_a?(Hash)

          if Coercer.performable?(type)
            coerced = Coercer.perform(value, type)
            return coerced unless coerced.nil?
          end

          value
        end

        def coerce_array(array, param_options, definition)
          array.map do |item|
            if param_options[:shape] && item.is_a?(Hash)
              coerce_hash(item, param_options[:shape])
            elsif param_options[:of] && Coercer.performable?(param_options[:of])
              coerced = Coercer.perform(item, param_options[:of])
              coerced.nil? ? item : coerced
            elsif param_options[:of] && item.is_a?(Hash)
              custom_type_block = definition.contract_class.resolve_custom_type(param_options[:of])
              if custom_type_block
                custom_definition = Definition.new(type: :body, contract_class: definition.contract_class)
                custom_definition.instance_eval(&custom_type_block)
                coerce_hash(item, custom_definition)
              else
                item
              end
            else
              item
            end
          end
        end

        def coerce_union(value, union_def, definition)
          if union_def.variants.any? { |variant| variant[:type] == :boolean }
            coerced = Coercer.perform(value, :boolean)
            return coerced unless coerced.nil?
          end

          union_def.variants.each do |variant|
            variant_type = variant[:type]
            variant_of = variant[:of]

            if variant_type == :array && value.is_a?(Array) && variant_of
              custom_type_block = definition.contract_class.resolve_custom_type(variant_of)
              if custom_type_block
                custom_definition = Definition.new(type: :body, contract_class: definition.contract_class)
                custom_definition.instance_eval(&custom_type_block)

                coerced_array = value.map do |item|
                  item.is_a?(Hash) ? coerce_hash(item, custom_definition) : item
                end
                return coerced_array
              end
            end

            custom_type_block = definition.contract_class.resolve_custom_type(variant_type)
            next unless custom_type_block

            custom_definition = Definition.new(type: :body, contract_class: definition.contract_class)
            custom_definition.instance_eval(&custom_type_block)

            if value.is_a?(Hash)
              coerced = coerce_hash(value, custom_definition)
              return coerced
            end
          end

          value
        end
      end
    end
  end
end
