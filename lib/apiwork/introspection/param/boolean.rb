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
      # @example Enum
      #   if param.enum?
      #     param.enum      # => [true]
      #     param.enum_reference? # => false
      #   end
      class Boolean < Base
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
        # @return [Array<Boolean>, Symbol, nil]
        def enum
          @dump[:enum]
        end

        # @api public
        # @return [Boolean]
        def enum_reference?
          @dump[:enum].is_a?(Symbol)
        end

        # @api public
        # @return [Boolean]
        def boolean?
          true
        end

        # @api public
        # Whether this param supports format hints.
        #
        # @return [Boolean]
        def formattable?
          false
        end
      end
    end
  end
end
