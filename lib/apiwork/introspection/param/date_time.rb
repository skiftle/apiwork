# frozen_string_literal: true

module Apiwork
  module Introspection
    module Param
      # @api public
      # DateTime param representing date and time values with timezone.
      #
      # @example Basic usage
      #   param.type         # => :datetime
      #   param.scalar?      # => true
      #   param.datetime?    # => true
      #
      # @example Capabilities
      #   param.formattable? # => false
      #
      # @example Enum
      #   if param.enum?
      #     param.enum      # => ["2024-01-01T00:00:00Z"]
      #     param.enum_ref? # => false
      #   end
      class DateTime < Base
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
        def enum_ref?
          @dump[:enum].is_a?(Symbol)
        end

        # @api public
        # Whether this param is a datetime.
        #
        # @return [Boolean]
        def datetime?
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
