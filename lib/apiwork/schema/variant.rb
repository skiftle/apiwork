# frozen_string_literal: true

module Apiwork
  module Schema
    # @api public
    # Represents a variant in a discriminated union.
    class Variant
      # @api public
      # @return [String] the discriminator value
      attr_reader :type

      attr_reader :schema_class

      def initialize(schema_class, type)
        @schema_class = schema_class
        @type = type
      end
    end
  end
end
