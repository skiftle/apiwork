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
      # @example Enum
      #   if param.enum?
      #     param.enum      # => ["SGVsbG8=", "V29ybGQ="]
      #     param.enum_reference? # => false
      #   end
      class Binary < Base
        # @api public
        # Whether this param is scalar.
        #
        # @return [Boolean]
        def scalar?
          true
        end

        # @api public
        # Whether this param is an enum.
        #
        # @return [Boolean]
        def enum?
          @dump[:enum].present?
        end

        # @api public
        # The enum values for this param.
        #
        # @return [Array<String>, Symbol, nil]
        def enum
          @dump[:enum]
        end

        # @api public
        # Whether this param is an enum reference.
        #
        # @return [Boolean]
        def enum_reference?
          @dump[:enum].is_a?(Symbol)
        end

        # @api public
        # Whether this param is binary.
        #
        # @return [Boolean]
        def binary?
          true
        end

        # @api public
        # Whether this param is formattable.
        #
        # @return [Boolean]
        def formattable?
          false
        end
      end
    end
  end
end
