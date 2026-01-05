# frozen_string_literal: true

module Apiwork
  module Introspection
    module Param
      # @api public
      # Ref param representing a reference to a named type.
      #
      # Used when a param references a shared type definition.
      #
      # @example Basic usage
      #   param.type    # => :ref
      #   param.ref?    # => true
      #   param.scalar? # => false
      #
      # @example Reference
      #   param.ref     # => :address (the referenced type name)
      class Ref < Base
        # @api public
        # @return [Symbol] the referenced type name
        def ref
          @dump[:ref]
        end

        # @api public
        # @return [Boolean] true if this is a type reference param
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
