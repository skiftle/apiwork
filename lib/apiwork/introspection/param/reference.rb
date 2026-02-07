# frozen_string_literal: true

module Apiwork
  module Introspection
    module Param
      # @api public
      # Reference param representing a reference to a named type.
      #
      # Used when a param references a shared type definition.
      #
      # @example Basic usage
      #   param.type       # => :reference
      #   param.reference? # => true
      #   param.scalar?    # => false
      #
      # @example Reference
      #   param.reference  # => :address (the referenced type name)
      class Reference < Base
        # @api public
        # The referenced type name for this param.
        #
        # @return [Symbol]
        def reference
          @dump[:reference]
        end

        # @api public
        # Whether this param is a reference.
        #
        # @return [Boolean]
        def reference?
          true
        end

        # @api public
        # Converts this param to a hash.
        #
        # @return [Hash]
        def to_h
          result = super
          result[:reference] = reference
          result
        end
      end
    end
  end
end
