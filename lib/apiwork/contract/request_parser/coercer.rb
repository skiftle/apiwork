# frozen_string_literal: true

module Apiwork
  module Contract
    class RequestParser
      module Coercer
        module_function

        COERCERS = {
          integer: lambda { |value|
            return nil if value.nil?
            return value if value.is_a?(Integer)

            Integer(value) if value.is_a?(String) && value.match?(/\A-?\d+\z/)
          },

          float: lambda { |value|
            return nil if value.nil?
            return value if value.is_a?(Float) || value.is_a?(Integer)

            Float(value) if value.is_a?(String)
          },

          decimal: lambda { |value|
            return nil if value.nil?
            return value if value.is_a?(BigDecimal)

            BigDecimal(value.to_s) if value.is_a?(Numeric) || value.is_a?(String)
          },

          boolean: lambda { |value|
            return nil if value.nil?
            return value if [true, false].include?(value)
            return true if value.to_s.downcase.in?(%w[true 1 yes])
            return false if value.to_s.downcase.in?(%w[false 0 no])

            nil
          },

          date: lambda { |value|
            return nil if value.nil?
            return value if value.is_a?(Date)

            Date.parse(value) if value.is_a?(String)
          },

          datetime: lambda { |value|
            return nil if value.nil?
            return value if value.is_a?(Time) || value.is_a?(DateTime) || value.is_a?(ActiveSupport::TimeWithZone)

            Time.zone.parse(value) if value.is_a?(String)
          },

          uuid: lambda { |value|
            return nil if value.nil?
            return value if value.is_a?(String) && value.match?(/\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/i)

            nil
          },

          string: lambda { |value|
            return nil if value.nil?
            return value if value.is_a?(String)

            value.to_s
          }
        }.freeze

        def perform(value, type)
          coercer = COERCERS[type]
          return value unless coercer

          begin
            coercer.call(value)
          rescue ArgumentError, TypeError
            nil
          end
        end

        def performable?(type)
          COERCERS.key?(type)
        end
      end
    end
  end
end
