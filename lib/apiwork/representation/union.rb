# frozen_string_literal: true

module Apiwork
  module Representation
    # @api public
    # Configuration for discriminated union representations.
    #
    # Holds the discriminator field name, Rails column, and registered variants.
    # Used by adapters to serialize records based on their actual type.
    #
    # @example
    #   ClientRepresentation.union.discriminator # => :kind
    #   ClientRepresentation.union.column        # => :type
    #   ClientRepresentation.union.variants      # => {person: Union::Variant, company: Union::Variant}
    #
    # @see Representation::Base.discriminated!
    class Union
      # @api public
      # @return [Symbol] key name for the discriminator
      attr_reader :discriminator

      # @api public
      # @return [Symbol] Rails column name (typically :type)
      attr_reader :column

      # @api public
      # @return [Hash{Symbol => Variant}] registered variants
      attr_reader :variants

      def initialize(column:, discriminator:)
        @discriminator = discriminator
        @column = column
        @variants = {}
      end

      # @api public
      # Resolves which variant to use for a record.
      #
      # @param record [ActiveRecord::Base] the record to resolve
      # @return [Variant, nil] the matching variant or nil
      def resolve(record)
        type_value = record.public_send(column)
        variants.values.find { |variant| variant.type == type_value }
      end

      # @api public
      # Returns whether any variant has a tag different from its type.
      #
      # @return [Boolean] true if transformation is needed
      def needs_transform?
        variants.any? { |tag, variant| tag.to_s != variant.type }
      end

      # @api public
      # Returns a mapping of tags to Rails STI types.
      #
      # @return [Hash{Symbol => String}] tag to type mapping
      def mapping
        variants.transform_values(&:type)
      end

      def register(variant)
        @variants = variants.merge(variant.tag => variant).freeze
      end
    end
  end
end
