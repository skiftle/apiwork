# frozen_string_literal: true

module Apiwork
  module Introspection
    module Param
      # @api public
      # Boolean param representing true/false values.
      #
      # @example Basic usage
      #   param.type         # => :boolean
      #   param.scalar?      # => true
      #   param.boolean?     # => true
      #
      # @example Capabilities
      #   param.formattable? # => false
      #
      # @example Enum (scalar-only, use guard)
      #   if param.scalar? && param.enum?
      #     param.enum      # => [true]
      #     param.enum_ref? # => false
      #   end
      class Boolean < Base
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
        #     param.enum # => [true]
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
        # @return [Boolean] true if this is a boolean param
        def boolean?
          true
        end

        # @api public
        # @return [Boolean] false — booleans do not support format constraints
        # @see #scalar?
        def formattable?
          false
        end
      end
    end
  end
end
