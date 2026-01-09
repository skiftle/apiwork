# frozen_string_literal: true

module Apiwork
  module API
    class Union
      attr_reader :discriminator,
                  :variants

      def initialize(discriminator: nil, object: -> { Object.new })
        @discriminator = discriminator
        @object = object
        @variants = []
      end

      def variant(enum: nil, of: nil, partial: nil, tag: nil, type:, &block)
        validate_tag!(tag)

        shape = if block && type == :object
                  builder = @object.call
                  builder.instance_eval(&block)
                  builder
                end

        @variants << {
          enum:,
          of:,
          partial:,
          shape:,
          tag:,
          type:,
        }.compact
      end

      private

      def validate_tag!(tag)
        raise ArgumentError, 'tag can only be used when union has a discriminator' if tag.present? && @discriminator.nil?

        return unless @discriminator.present? && tag.blank?

        raise ArgumentError, 'tag is required for all variants when union has a discriminator'
      end
    end
  end
end
