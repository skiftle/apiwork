# frozen_string_literal: true

module Apiwork
  module Introspection
    module Param
      # @api public
      # Date param representing date values (year, month, day).
      #
      # @example Basic usage
      #   param.type         # => :date
      #   param.scalar?      # => true
      #   param.date?        # => true
      #
      # @example Capabilities
      #   param.formattable? # => false
      #
      # @example Enum
      #   if param.enum?
      #     param.enum      # => ["2024-01-01", "2024-12-31"]
      #     param.enum_reference? # => false
      #   end
      class Date < Base
        # @api public
        # Whether this param is scalar.
        #
        # @return [Boolean]
        def scalar?
          true
        end

        # @api public
        # Whether this param is an enum.
        #
        # @return [Boolean]
        def enum?
          @dump[:enum].present?
        end

        # @api public
        # The enum values for this param.
        #
        # @return [Array<String>, Symbol, nil]
        def enum
          @dump[:enum]
        end

        # @api public
        # Whether this param is an enum reference.
        #
        # @return [Boolean]
        def enum_reference?
          @dump[:enum].is_a?(Symbol)
        end

        # @api public
        # Whether this param is a date.
        #
        # @return [Boolean]
        def date?
          true
        end

        # @api public
        # Whether this param is formattable.
        #
        # @return [Boolean]
        def formattable?
          false
        end
      end
    end
  end
end
