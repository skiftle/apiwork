# frozen_string_literal: true

module Apiwork
  module Introspection
    module Param
      # @api public
      # Type reference param.
      #
      # The type field contains the symbol name of the referenced type.
      #
      # @example
      #   param.type      # => :address (the custom type name)
      #   param.ref_type? # => true
      class RefType < Base
        # @api public
        # @return [Boolean] true for type reference params
        def ref_type?
          true
        end
      end
    end
  end
end
