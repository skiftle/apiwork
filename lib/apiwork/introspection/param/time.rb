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
        # @return [Boolean]
        def scalar?
          true
        end

        # @api public
        # @return [Boolean]
        def enum?
          @dump[:enum].present?
        end

        # @api public
        # @return [Array<String>, Symbol, nil]
        # @see #enum?
        def enum
          @dump[:enum]
        end

        # @api public
        # @return [Boolean]
        def enum_ref?
          @dump[:enum].is_a?(Symbol)
        end

        # @api public
        # @return [Boolean]
        def time?
          true
        end

        # @api public
        # @return [Boolean]
        def formattable?
          false
        end
      end
    end
  end
end
