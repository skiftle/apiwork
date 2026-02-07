# frozen_string_literal: true

module Apiwork
  module Introspection
    module Param
      # @api public
      # UUID param representing universally unique identifier values.
      #
      # @example Basic usage
      #   param.type         # => :uuid
      #   param.scalar?      # => true
      #   param.uuid?        # => true
      #
      # @example Capabilities
      #   param.formattable? # => false
      #
      # @example Enum
      #   if param.enum?
      #     param.enum      # => ["550e8400-e29b-41d4-a716-446655440000"]
      #     param.enum_ref? # => false
      #   end
      class UUID < Base
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
        def uuid?
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
