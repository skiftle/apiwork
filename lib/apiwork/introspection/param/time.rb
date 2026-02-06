# frozen_string_literal: true

module Apiwork
  module Introspection
    module Param
      # @api public
      # Time param representing time-of-day values.
      #
      # @example Basic usage
      #   param.type         # => :time
      #   param.scalar?      # => true
      #   param.time?        # => true
      #
      # @example Capabilities
      #   param.formattable? # => false
      #
      # @example Enum
      #   if param.enum?
      #     param.enum      # => ["09:00", "17:00"]
      #     param.enum_ref? # => false
      #   end
      class Time < Base
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
        # @return [Array<String>, Symbol, nil] enum values (Array) or reference name (Symbol)
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
        # @return [Boolean] true if this is a time param
        def time?
          true
        end

        # @api public
        # @return [Boolean] false — times do not support format constraints
        def formattable?
          false
        end
      end
    end
  end
end
