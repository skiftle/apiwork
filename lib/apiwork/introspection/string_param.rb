# frozen_string_literal: true

module Apiwork
  module Introspection
    # @api public
    # String param.
    #
    # @example
    #   param.type    # => :string
    #   param.format  # => :email, :uuid, :uri, :url, :ipv4, :ipv6, :hostname, :password
    #   param.min     # => 1 (minimum string length)
    #   param.max     # => 255 (maximum string length)
    #   param.scalar? # => true
    class StringParam < ScalarParam
      # @api public
      # @return [Symbol, nil] format constraint
      #   Supported formats: :email, :uuid, :uri, :url, :ipv4, :ipv6, :hostname, :password
      def format
        @dump[:format]
      end

      # @api public
      # @return [Integer, nil] minimum string length
      def min
        @dump[:min]
      end

      # @api public
      # @return [Integer, nil] maximum string length
      def max
        @dump[:max]
      end
    end
  end
end
