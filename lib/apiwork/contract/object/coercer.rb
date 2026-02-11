# frozen_string_literal: true

module Apiwork
  module Contract
    class Object
      class Coercer
        PRIMITIVES = {
          boolean: lambda { |value|
            return value if [true, false].include?(value)
            return true if %w[true 1 yes].include?(value.to_s.downcase)
            return false if %w[false 0 no].include?(value.to_s.downcase)

            nil
          },
          date: lambda { |value|
            return value if value.is_a?(Date)

            Date.parse(value) if value.is_a?(String)
          },
          datetime: lambda { |value|
            return value if value.is_a?(Time) || value.is_a?(DateTime) || value.is_a?(ActiveSupport::TimeWithZone)

            Time.zone.parse(value) if value.is_a?(String)
          },
          decimal: lambda { |value|
            return value if value.is_a?(BigDecimal)

            BigDecimal(value.to_s) if value.is_a?(Numeric) || value.is_a?(String)
          },
          integer: lambda { |value|
            return value if value.is_a?(Integer)

            Integer(value) if value.is_a?(String) && value.match?(/\A-?\d+\z/)
          },
          number: lambda { |value|
            return value if value.is_a?(Float) || value.is_a?(Integer)
            return nil if value.is_a?(String) && value.blank?

            Float(value) if value.is_a?(String)
          },
          string: lambda { |value|
            return value if value.is_a?(String)

            value.to_s
          },
          time: lambda { |value|
            return value if value.is_a?(Time) || value.is_a?(DateTime) || value.is_a?(ActiveSupport::TimeWithZone)

            Time.zone.parse("2000-01-01T#{value}") if value.is_a?(String) && value.match?(/\A\d{2}:\d{2}(:\d{2})?\z/)
          },
          uuid: lambda { |value|
            return value if value.is_a?(String) && value.match?(/\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/i)

            nil
          },
        }.freeze

        class << self
          def coerce(shape, hash)
            new(shape).coerce(hash)
          end
        end

        def initialize(shape)
          @shape = shape
          @type_cache = {}
        end

        def coerce(hash)
          coerced = hash.dup

          shape.params.each do |name, param_options|
            next unless coerced.key?(name)

            coerced[name] = coerce_value(coerced[name], param_options)
          end

          coerced
        end

        private

        attr_reader :shape, :type_cache

        def coerce_value(value, param_options)
          type = param_options[:type]

          return coerce_union(value, param_options[:union]) if type == :union
          return coerce_array(value, param_options) if type == :array && value.is_a?(Array)
          return Coercer.new(param_options[:shape]).coerce(value) if param_options[:shape] && value.is_a?(Hash)

          if value.is_a?(Hash) && type && !PRIMITIVES.key?(type)
            custom_shape = resolve_custom_shape(type)
            return Coercer.new(custom_shape).coerce(value) if custom_shape
          end

          coerced = coerce_primitive(value, type)
          coerced.nil? ? value : coerced
        end

        def coerce_array(array, param_options)
          custom_shape = nil

          custom_shape = resolve_custom_shape(param_options[:of]) if param_options[:of] && !PRIMITIVES.key?(param_options[:of])

          array.map do |item|
            if param_options[:shape] && item.is_a?(Hash)
              Coercer.new(param_options[:shape]).coerce(item)
            elsif param_options[:of] && PRIMITIVES.key?(param_options[:of])
              coerced = coerce_primitive(item, param_options[:of])
              coerced.nil? ? item : coerced
            elsif custom_shape && item.is_a?(Hash)
              Coercer.new(custom_shape).coerce(item)
            else
              item
            end
          end
        end

        def coerce_union(value, union)
          if union.variants.any? { |variant| variant[:type] == :boolean }
            coerced = coerce_primitive(value, :boolean)
            return coerced unless coerced.nil?
          end

          discriminator = union.discriminator

          if discriminator && value.is_a?(Hash)
            discriminator_value = value[discriminator]
            matching_variant = union.variants.find do |variant|
              variant[:tag].to_s == discriminator_value.to_s
            end

            if matching_variant
              custom_shape = resolve_custom_shape(matching_variant[:type])
              return Coercer.new(custom_shape).coerce(value) if custom_shape
            end
          end

          union.variants.each do |variant|
            variant_type = variant[:type]
            variant_of = variant[:of]

            if variant_type == :array && value.is_a?(Array) && variant_of
              custom_shape = resolve_custom_shape(variant_of)
              if custom_shape
                return value.map do |item|
                  item.is_a?(Hash) ? Coercer.new(custom_shape).coerce(item) : item
                end
              end
            end

            next if discriminator

            custom_shape = resolve_custom_shape(variant_type)
            next unless custom_shape

            return Coercer.new(custom_shape).coerce(value) if value.is_a?(Hash)
          end

          value
        end

        def coerce_primitive(value, type)
          return nil if value.nil?

          coercer = PRIMITIVES[type]
          return nil unless coercer

          begin
            coercer.call(value)
          rescue ArgumentError, TypeError
            nil
          end
        end

        def resolve_custom_shape(type_name)
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
