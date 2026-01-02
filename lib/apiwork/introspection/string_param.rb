# frozen_string_literal: true

module Apiwork
  module Introspection
    # @api public
    # Param subclass for string types.
    #
    # @example
    #   param.type        # => :string
    #   param.format      # => :email, :uuid, :uri, etc.
    #   param.string?     # => true
    class StringParam < Param
      # @api public
      # @return [Symbol, nil] format hint (:email, :uuid, :uri, etc.)
      def format
        @dump[:format]
      end

      # @api public
      # @return [Boolean] always true for StringParam
      def string?
        true
      end

      # @api public
      # @return [Hash] structured representation
      def to_h
        result = super
        result[:format] = format
        result
      end
    end
  end
end
