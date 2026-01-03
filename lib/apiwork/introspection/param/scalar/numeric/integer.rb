# frozen_string_literal: true

module Apiwork
  module Introspection
    module Param
      class Scalar
        class Numeric
          # @api public
          # Integer param.
          #
          # @example
          #   param.type        # => :integer
          #   param.min         # => 0
          #   param.max         # => 100
          #   param.format      # => :int32, :int64
          #   param.scalar?     # => true
          #   param.numeric?    # => true
          #   param.boundable?  # => true
          #   param.formattable? # => true
          #   param.integer?    # => true
          class Integer < Numeric
            # @api public
            # @return [Symbol, nil] format constraint (:int32, :int64)
            def format
              @dump[:format]
            end

            # @api public
            # @return [Boolean] true - integers support format constraints (:int32, :int64)
            def formattable?
              true
            end

            # @api public
            # @return [Boolean] true for integer params
            def integer?
              true
            end
          end
        end
      end
    end
  end
end
