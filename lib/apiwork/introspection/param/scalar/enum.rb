# frozen_string_literal: true

module Apiwork
  module Introspection
    module Param
      class Scalar
        class Enum < Scalar
          # @api public
          # @return [Boolean] true for all enum types
          def enum?
            true
          end

          # @api public
          # @return [Boolean] whether this is a reference to a named enum
          def ref?
            false
          end

          # @api public
          # @return [Boolean] whether this has inline enum values
          def inline?
            false
          end

          # @api public
          # @return [Symbol, Array] enum reference or inline values
          def enum
            @dump[:enum]
          end

          # @api public
          # @return [Hash] structured representation
          def to_h
            result = super
            result[:enum] = enum
            result
          end
        end
      end
    end
  end
end
