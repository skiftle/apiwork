# frozen_string_literal: true

module Apiwork
  module Contract
    # Type validation for Contract system
    class TypeChecker
      class << self
        def valid?(value, field_def)
          # Handle nil based on nullable
          if value.nil?
            return field_def.allows_nil?
          end

          # Empty string coercion to nil (if nullable)
          if value == '' && field_def.allows_nil?
            return true
          end

          # Validate type
          validate_type(value, field_def.type)
        end

        def validate_type(value, type)
          case type
          when :uuid
            value.is_a?(String) && value.match?(/\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/i)
          when :boolean
            [true, false].include?(value)
          when :string
            value.is_a?(String)
          when :integer
            value.is_a?(Integer)
          when :float
            value.is_a?(Float) || value.is_a?(Integer)
          when :decimal
            value.is_a?(BigDecimal) || value.is_a?(Numeric)
          when :date
            value.is_a?(Date)
          when :datetime
            value.is_a?(Time) || value.is_a?(DateTime) || value.is_a?(ActiveSupport::TimeWithZone)
          when :json, :jsonb
            value.is_a?(Hash) || value.is_a?(Array)
          when Hash
            validate_collection(value, type)
          else
            false
          end
        end

        def validate_collection(value, type_spec)
          return false unless value.is_a?(Array)

          if type_spec[:array]
            element_type = type_spec[:array]

            # Check max items
            max_items = Apiwork.configuration.max_array_items
            if value.length > max_items
              raise ValidationError.array_too_large(
                size: value.length,
                max_size: max_items,
                path: []
              )
            end

            value.all? do |item|
              if element_type.is_a?(Symbol)
                validate_type(item, element_type)
              else
                true  # Complex element type handled by recursive validation
              end
            end
          else
            true
          end
        end
      end
    end
  end
end
