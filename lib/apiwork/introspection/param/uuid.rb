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
      # @example Enum (scalar-only, use guard)
      #   if param.scalar? && param.enum?
      #     param.enum      # => ["550e8400-e29b-41d4-a716-446655440000"]
      #     param.enum_ref? # => false
      #   end
      class UUID < Base
        # @api public
        # @return [Boolean] true if this is a scalar type
        def scalar?
          true
        end

        # @api public
        # @return [Boolean] true if this param has enum constraints
        # @see #scalar?
        # @example
        #   if param.scalar? && param.enum?
        #     param.enum # => ["550e8400-e29b-41d4-a716-446655440000"]
        #   end
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
        # @see #enum?
        def enum_ref?
          @dump[:enum].is_a?(Symbol)
        end

        # @api public
        # @return [Boolean] true if this is a UUID param
        def uuid?
          true
        end

        # @api public
        # @return [Boolean] false — UUIDs do not support format constraints
        # @see #scalar?
        def formattable?
          false
        end
      end
    end
  end
end
