# frozen_string_literal: true

module Apiwork
  module Schema
    # @api public
    # Represents a variant in a discriminated union.
    #
    # Variants map discriminator values to their schema classes.
    # Used by adapters to serialize records based on their actual type.
    #
    # @example
    #   variant = VehicleSchema.variants[:car]
    #   variant.type          # => "Car"
    #   variant.schema_class  # => CarSchema
    class Variant
      # @api public
      # @return [Schema::Base] the schema class for this variant
      attr_reader :schema_class

      # @api public
      # @return [String] the discriminator value
      attr_reader :type

      def initialize(schema_class, type)
        @schema_class = schema_class
        @type = type
      end
    end
  end
end
