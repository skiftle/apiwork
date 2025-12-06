# frozen_string_literal: true

module Apiwork
  module Contract
    class RequestParser
      module Coercion
        module_function

        def coerce_hash(hash, definition, type_cache: nil)
          coerced = hash.dup

          definition.params.each do |name, param_options|
            next unless coerced.key?(name)

            coerced[name] = coerce_value(coerced[name], param_options, definition, type_cache: type_cache)
          end

          coerced
        end

        def coerce_value(value, param_options, definition, type_cache: nil)
          type = param_options[:type]

          return coerce_union(value, param_options[:union], definition, type_cache: type_cache) if type == :union
          return coerce_array(value, param_options, definition, type_cache: type_cache) if type == :array && value.is_a?(Array)
          return coerce_hash(value, param_options[:shape], type_cache: type_cache) if param_options[:shape] && value.is_a?(Hash)

          if Coercer.performable?(type)
            coerced = Coercer.perform(value, type)
            return coerced unless coerced.nil?
          end

          value
        end

        def coerce_array(array, param_options, definition, type_cache: nil)
          type_cache ||= {}
          custom_definition = nil

          if param_options[:of] && !Coercer.performable?(param_options[:of])
            custom_definition = resolve_custom_definition(param_options[:of], definition, type_cache)
          end

          array.map do |item|
            if param_options[:shape] && item.is_a?(Hash)
              coerce_hash(item, param_options[:shape], type_cache: type_cache)
            elsif param_options[:of] && Coercer.performable?(param_options[:of])
              coerced = Coercer.perform(item, param_options[:of])
              coerced.nil? ? item : coerced
            elsif custom_definition && item.is_a?(Hash)
              coerce_hash(item, custom_definition, type_cache: type_cache)
            else
              item
            end
          end
        end

        def coerce_union(value, union_definition, definition, type_cache: nil)
          type_cache ||= {}

          if union_definition.variants.any? { |variant| variant[:type] == :boolean }
            coerced = Coercer.perform(value, :boolean)
            return coerced unless coerced.nil?
          end

          union_definition.variants.each do |variant|
            variant_type = variant[:type]
            variant_of = variant[:of]

            if variant_type == :array && value.is_a?(Array) && variant_of
              custom_definition = resolve_custom_definition(variant_of, definition, type_cache)
              if custom_definition
                coerced_array = value.map do |item|
                  item.is_a?(Hash) ? coerce_hash(item, custom_definition, type_cache: type_cache) : item
                end
                return coerced_array
              end
            end

            custom_definition = resolve_custom_definition(variant_type, definition, type_cache)
            next unless custom_definition

            if value.is_a?(Hash)
              coerced = coerce_hash(value, custom_definition, type_cache: type_cache)
              return coerced
            end
          end

          value
        end

        def resolve_custom_definition(type_name, definition, type_cache)
          return type_cache[type_name] if type_cache.key?(type_name)

          custom_type_block = definition.contract_class.resolve_custom_type(type_name)
          return type_cache[type_name] = nil unless custom_type_block

          custom_definition = Definition.new(type: :body, contract_class: definition.contract_class)
          custom_type_block.each { |block| custom_definition.instance_eval(&block) }
          type_cache[type_name] = custom_definition
        end
      end
    end
  end
end
