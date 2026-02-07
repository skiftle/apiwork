# frozen_string_literal: true

module Apiwork
  module Introspection
    module Param
      # @api public
      # Unknown param representing an unrecognized type.
      #
      # Used as a fallback when the type cannot be determined during introspection.
      #
      # @example Basic usage
      #   param.type     # => :unknown
      #   param.unknown? # => true
      #   param.scalar?  # => false
      class Unknown < Base
        # @api public
        # @return [Boolean]
        def unknown?
          true
        end
      end
    end
  end
end
