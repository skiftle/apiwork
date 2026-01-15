# frozen_string_literal: true

module Apiwork
  module Schema
    class Union
      # @api public
      # Represents a variant in a discriminated union schema.
      #
      # Variants map discriminator tags to their schema classes.
      # Used by adapters to serialize records based on their actual type.
      #
      # @example
      #   variant = ClientSchema.union.variants[:person]
      #   variant.tag           # => :person
      #   variant.type          # => "PersonClient"
      #   variant.schema_class  # => PersonClientSchema
      class Variant
        # @api public
        # @return [Class] the schema class for this variant
        attr_reader :schema_class

        # @api public
        # @return [Symbol] the discriminator tag
        attr_reader :tag

        # @api public
        # @return [String] the Rails STI type
        attr_reader :type

        def initialize(schema_class:, tag:, type:)
          @schema_class = schema_class
          @tag = tag
          @type = type
        end
      end
    end
  end
end
