# frozen_string_literal: true

module Apiwork
  module Contract
    # Type coercion for Contract system
    # Converts string inputs to appropriate Ruby types for contract validation
    class Coercer
      COERCERS = {
        integer: lambda { |val|
          return nil if val.nil?
          return val if val.is_a?(Integer)

          Integer(val) if val.is_a?(String) && val.match?(/\A-?\d+\z/)
        },

        float: lambda { |val|
          return nil if val.nil?
          return val if val.is_a?(Float) || val.is_a?(Integer)

          Float(val) if val.is_a?(String)
        },

        decimal: lambda { |val|
          return nil if val.nil?
          return val if val.is_a?(BigDecimal)

          BigDecimal(val.to_s) if val.is_a?(Numeric) || val.is_a?(String)
        },

        boolean: lambda { |val|
          return nil if val.nil?
          return val if [true, false].include?(val)
          return true if val.to_s.downcase.in?(%w[true 1 yes])
          return false if val.to_s.downcase.in?(%w[false 0 no])

          nil
        },

        date: lambda { |val|
          return nil if val.nil?
          return val if val.is_a?(Date)

          Date.parse(val) if val.is_a?(String)
        },

        datetime: lambda { |val|
          return nil if val.nil?
          return val if val.is_a?(Time) || val.is_a?(DateTime) || val.is_a?(ActiveSupport::TimeWithZone)

          Time.zone.parse(val) if val.is_a?(String)
        },

        uuid: lambda { |val|
          return nil if val.nil?
          if val.is_a?(String) && val.match?(/\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/i)
            return val
          end

          nil
        },

        string: lambda { |val|
          return nil if val.nil?
          return val if val.is_a?(String)

          val.to_s
        }
      }.freeze

      class << self
        def coerce(value, type)
          coercer = COERCERS[type]
          return value unless coercer

          begin
            coercer.call(value)
          rescue ArgumentError, TypeError
            nil # Coercion failed - will be caught by type validation
          end
        end

        def can_coerce?(type)
          COERCERS.key?(type)
        end
      end
    end
  end
end
