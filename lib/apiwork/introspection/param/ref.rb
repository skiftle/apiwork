# frozen_string_literal: true

module Apiwork
  module Introspection
    module Param
      # @api public
      # Type reference param.
      #
      # @example
      #   param.type      # => :ref
      #   param.ref       # => :address (the referenced type name)
      #   param.ref? # => true
      class Ref < Base
        # @api public
        # @return [Symbol] the referenced type name
        def ref
          @dump[:ref]
        end

        # @api public
        # @return [Boolean] true for type reference params
        def ref?
          true
        end

        # @api public
        # @return [Hash] structured representation
        def to_h
          result = super
          result[:ref] = ref
          result
        end
      end
    end
  end
end
