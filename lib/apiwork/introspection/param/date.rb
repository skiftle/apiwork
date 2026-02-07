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
      # @example Enum
      #   if param.enum?
      #     param.enum      # => ["2024-01-01", "2024-12-31"]
      #     param.enum_ref? # => false
      #   end
      class Date < Base
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
        def date?
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
