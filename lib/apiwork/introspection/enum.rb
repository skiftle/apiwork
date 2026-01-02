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
      # @return [Array<String>] allowed enum values
      def values
        @dump[:values] || []
      end

      # @api public
      # @return [String, nil] enum description
      def description
        @dump[:description]
      end

      # @api public
      # @return [String, nil] example value
      def example
        @dump[:example]
      end

      # @api public
      # @return [Boolean] whether this enum is deprecated
      def deprecated?
        @dump[:deprecated] == true
      end

      # @api public
      # @return [Hash] structured representation
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
