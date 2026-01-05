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
      # @example Enum (scalar-only, use guard)
      #   if param.scalar? && param.enum?
      #     param.enum      # => ["2024-01-01", "2024-12-31"]
      #     param.enum_ref? # => false
      #   end
      class Date < Base
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
        #     param.enum # => ["2024-01-01", "2024-12-31"]
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
        # @return [Boolean] true if this is a date param
        def date?
          true
        end

        # @api public
        # @return [Boolean] false — dates do not support format constraints
        # @see #scalar?
        def formattable?
          false
        end
      end
    end
  end
end
