# frozen_string_literal: true

module Apiwork
  module Introspection
    module Param
      # @api public
      # Binary param representing base64-encoded binary data.
      #
      # @example Basic usage
      #   param.type         # => :binary
      #   param.scalar?      # => true
      #   param.binary?      # => true
      #
      # @example Capabilities
      #   param.formattable? # => false
      #
      # @example Enum (scalar-only, use guard)
      #   if param.scalar? && param.enum?
      #     param.enum      # => ["SGVsbG8=", "V29ybGQ="]
      #     param.enum_ref? # => false
      #   end
      class Binary < Base
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
        #     param.enum # => ["SGVsbG8=", "V29ybGQ="]
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
        # @return [Boolean] true if this is a binary param
        def binary?
          true
        end

        # @api public
        # @return [Boolean] false — binaries do not support format constraints
        # @see #scalar?
        def formattable?
          false
        end
      end
    end
  end
end
