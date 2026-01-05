# frozen_string_literal: true

module Apiwork
  module Introspection
    module Param
      # @api public
      # UUID param.
      #
      # @example
      #   param.type    # => :uuid
      #   param.scalar? # => true
      #   param.uuid?   # => true
      class UUID < Base
        # @api public
        # @return [Boolean] true for all scalar types
        def scalar?
          true
        end

        # @api public
        # @return [Boolean] whether this scalar has enum constraints
        def enum?
          @dump[:enum].present?
        end

        # @api public
        # @return [Array, Symbol, nil] inline values (Array) or ref name (Symbol)
        def enum
          @dump[:enum]
        end

        # @api public
        # @return [Boolean] whether this is a reference to a named enum
        def enum_ref?
          @dump[:enum].is_a?(Symbol)
        end

        # @api public
        # @return [Boolean] true for UUID params
        def uuid?
          true
        end

        # @api public
        # @return [Boolean] false - UUIDs do not support format constraints
        def formattable?
          false
        end
      end
    end
  end
end
