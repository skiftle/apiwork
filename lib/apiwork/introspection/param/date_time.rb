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
        # @return [Boolean] true if this is a scalar type
        def scalar?
          true
        end

        # @api public
        # @return [Boolean] true if this param has enum constraints
        def enum?
          @dump[:enum].present?
        end

        # @api public
        # @return [Array, Symbol, nil] enum values (Array) or reference name (Symbol)
        # @see #enum?
        def enum
          @dump[:enum]
        end

        # @api public
        # @return [Boolean] true if enum is a reference to a named enum
        def enum_ref?
          @dump[:enum].is_a?(Symbol)
        end

        # @api public
        # @return [Boolean] true if this is a datetime param
        def datetime?
          true
        end

        # @api public
        # @return [Boolean] false — datetimes do not support format constraints
        def formattable?
          false
        end
      end
    end
  end
end
