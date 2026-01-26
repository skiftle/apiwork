# frozen_string_literal: true

module Apiwork
  module Representation
    class Union
      # @api public
      # Represents a variant in a discriminated union representation.
      #
      # Variants map discriminator tags to their representation classes.
      # Used by adapters to serialize records based on their actual type.
      #
      # @example
      #   variant = ClientRepresentation.union.variants[:person]
      #   variant.tag                 # => :person
      #   variant.type                # => "PersonClient"
      #   variant.representation_class # => PersonClientRepresentation
      class Variant
        # @api public
        # @return [Class] the representation class for this variant
        attr_reader :representation_class

        # @api public
        # @return [Symbol] the discriminator tag
        attr_reader :tag

        # @api public
        # @return [String] the Rails STI type
        attr_reader :type

        def initialize(representation_class:, tag:, type:)
          @representation_class = representation_class
          @tag = tag
          @type = type
        end
      end
    end
  end
end
