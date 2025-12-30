# frozen_string_literal: true

module Apiwork
  module Contract
    class RequestParser
      class Coercer
        COERCERS = {
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
          float: lambda { |value|
            return value if value.is_a?(Float) || value.is_a?(Integer)
            return nil if value.is_a?(String) && value.blank?

            Float(value) if value.is_a?(String)
          },
          integer: lambda { |value|
            return value if value.is_a?(Integer)

            Integer(value) if value.is_a?(String) && value.match?(/\A-?\d+\z/)
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
          def perform(value, type)
            return nil if value.nil?

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
end
