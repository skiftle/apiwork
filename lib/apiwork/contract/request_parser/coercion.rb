# frozen_string_literal: true

module Apiwork
  module Contract
    class RequestParser
      class Coercion
        class << self
          def coerce_hash(hash, shape, type_cache: nil)
            coerced = hash.dup

            shape.params.each do |name, param_options|
              next unless coerced.key?(name)

              coerced[name] = coerce_value(coerced[name], param_options, shape, type_cache:)
            end

            coerced
          end

          def coerce_value(value, param_options, shape, type_cache: nil)
            type = param_options[:type]

            return coerce_union(value, param_options[:union], shape, type_cache:) if type == :union
            return coerce_array(value, param_options, shape, type_cache:) if type == :array && value.is_a?(Array)
            return coerce_hash(value, param_options[:shape], type_cache:) if param_options[:shape] && value.is_a?(Hash)

            if value.is_a?(Hash) && type && !Coercer.performable?(type)
              type_cache ||= {}
              custom_shape = resolve_custom_shape(type, shape, type_cache)
              return coerce_hash(value, custom_shape, type_cache:) if custom_shape
            end

            if Coercer.performable?(type)
              coerced = Coercer.perform(value, type)
              return coerced unless coerced.nil?
            end

            value
          end

          def coerce_array(array, param_options, shape, type_cache: nil)
            type_cache ||= {}
            custom_shape = nil

            if param_options[:of] && !Coercer.performable?(param_options[:of])
              custom_shape = resolve_custom_shape(param_options[:of], shape, type_cache)
            end

            array.map do |item|
              if param_options[:shape] && item.is_a?(Hash)
                coerce_hash(item, param_options[:shape], type_cache:)
              elsif param_options[:of] && Coercer.performable?(param_options[:of])
                coerced = Coercer.perform(item, param_options[:of])
                coerced.nil? ? item : coerced
              elsif custom_shape && item.is_a?(Hash)
                coerce_hash(item, custom_shape, type_cache:)
              else
                item
              end
            end
          end

          def coerce_union(value, union, shape, type_cache: nil)
            type_cache ||= {}

            if union.variants.any? { |variant| variant[:type] == :boolean }
              coerced = Coercer.perform(value, :boolean)
              return coerced unless coerced.nil?
            end

            discriminator = union.discriminator

            if discriminator && value.is_a?(Hash)
              discriminator_value = value[discriminator]
              matching_variant = union.variants.find do |variant|
                variant[:tag].to_s == discriminator_value.to_s
              end

              if matching_variant
                custom_shape = resolve_custom_shape(matching_variant[:type], shape, type_cache)
                return coerce_hash(value, custom_shape, type_cache:) if custom_shape
              end
            end

            union.variants.each do |variant|
              variant_type = variant[:type]
              variant_of = variant[:of]

              if variant_type == :array && value.is_a?(Array) && variant_of
                custom_shape = resolve_custom_shape(variant_of, shape, type_cache)
                if custom_shape
                  coerced_array = value.map do |item|
                    item.is_a?(Hash) ? coerce_hash(item, custom_shape, type_cache:) : item
                  end
                  return coerced_array
                end
              end

              next if discriminator

              custom_shape = resolve_custom_shape(variant_type, shape, type_cache)
              next unless custom_shape

              if value.is_a?(Hash)
                coerced = coerce_hash(value, custom_shape, type_cache:)
                return coerced
              end
            end

            value
          end

          private

          def resolve_custom_shape(type_name, shape, type_cache)
            return type_cache[type_name] if type_cache.key?(type_name)

            type_definition = shape.contract_class.resolve_custom_type(type_name)
            return type_cache[type_name] = nil unless type_definition

            custom_param = Object.new(shape.contract_class)
            custom_param.copy_type_definition_params(type_definition, custom_param)
            type_cache[type_name] = custom_param
          end
        end
      end
    end
  end
end
