# frozen_string_literal: true

module Apiwork
  module Introspection
    # @api public
    # Wraps enum type definitions.
    #
    # @example
    #   api.enums[:status].values       # => ["draft", "published", "archived"]
    #   api.enums[:status].description  # => "Document status"
    #   api.enums[:status].deprecated?  # => false
    class Enum
      def initialize(dump)
        @dump = dump
      end

      # @api public
      # @return [Array<String>]
      def values
        @dump[:values]
      end

      # @api public
      # @return [String, nil]
      def description
        @dump[:description]
      end

      # @api public
      # @return [String, nil]
      def example
        @dump[:example]
      end

      # @api public
      # @return [Boolean]
      def deprecated?
        @dump[:deprecated]
      end

      # @api public
      # @return [Hash]
      def to_h
        {
          deprecated: deprecated?,
          description: description,
          example: example,
          values: values,
        }
      end
    end
  end
end
