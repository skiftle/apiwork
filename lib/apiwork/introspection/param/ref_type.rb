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
      #   param.type # => :address (the custom type name)
      class RefType < Base
      end
    end
  end
end
