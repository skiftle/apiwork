# frozen_string_literal: true

module Apiwork
  module Introspection
    # @api public
    # Wraps enum type definitions.
    #
    # @example
    #   data.enums.each do |enum|
    #     enum.name         # => :status
    #     enum.values       # => ["draft", "published", "archived"]
    #     enum.description  # => "Document status"
    #     enum.deprecated?  # => false
    #   end
    class Enum
      # @api public
      # @return [Symbol] enum name
      attr_reader :name

      def initialize(name, dump)
        @name = name.to_sym
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
          name: name,
          values: values,
        }
      end
    end
  end
end
