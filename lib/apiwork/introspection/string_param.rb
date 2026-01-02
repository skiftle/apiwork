# frozen_string_literal: true

module Apiwork
  module Introspection
    # @api public
    # Param subclass for string types.
    #
    # @example
    #   param.type    # => :string
    #   param.format  # => :email, :uuid, :uri, etc.
    #   param.scalar? # => true
    class StringParam < ScalarParam
      # @api public
      # @return [Symbol, nil] format constraint (:email, :uuid, :uri, etc.)
      def format
        @dump[:format]
      end
    end
  end
end
