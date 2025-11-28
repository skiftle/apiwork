# frozen_string_literal: true

module Apiwork
  module Configuration
    module Validatable
      private

      def validate_type!(value)
        valid = case type
                when :symbol then value.is_a?(Symbol)
                when :string then value.is_a?(String)
                when :integer then value.is_a?(Integer)
                when :hash then value.is_a?(Hash)
                end
        raise ConfigurationError, "#{name} must be #{type}, got #{value.class}" unless valid
      end

      def validate_enum!(value)
        return if enum.include?(value)

        raise ConfigurationError, "#{name} must be one of #{enum.inspect}, got #{value.inspect}"
      end
    end
  end
end
