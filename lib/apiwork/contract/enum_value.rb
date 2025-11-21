# frozen_string_literal: true

module Apiwork
  module Contract
    module EnumValue
      module_function

      def values(enum)
        return nil if enum.nil?

        enum.is_a?(Hash) ? enum[:values] : enum
      end

      def valid?(value, enum)
        enum_values = values(enum)
        return true if enum_values.nil?

        enum_values.include?(value)
      end

      def format(enum)
        enum_values = values(enum)
        return '' if enum_values.blank?

        enum_values.join(', ')
      end
    end
  end
end
