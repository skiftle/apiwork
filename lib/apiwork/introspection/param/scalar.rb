# frozen_string_literal: true

module Apiwork
  module Introspection
    module Param
      class Scalar < Base
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
        # @return [Array, Hash, nil] enum values (Array) or ref ({ref: :name})
        def enum
          @dump[:enum]
        end

        # @api public
        # @return [Boolean] whether this is a reference to a named enum
        def ref_enum?
          @dump[:enum].is_a?(Hash)
        end
      end
    end
  end
end
