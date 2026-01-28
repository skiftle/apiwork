# frozen_string_literal: true

module Apiwork
  class Union
    attr_reader :discriminator,
                :variants

    def initialize(discriminator: nil)
      @discriminator = discriminator
      @variants = []
    end

    def variant(deprecated: nil, description: nil, partial: nil, tag: nil, &block)
      validate_tag!(tag)
      raise ArgumentError, 'variant requires a block' unless block

      element = build_element
      block.arity.positive? ? yield(element) : element.instance_eval(&block)
      element.validate!

      data = {
        deprecated:,
        description:,
        partial:,
        tag:,
        custom_type: element.custom_type,
        enum: element.enum,
        of: element.of_value,
        shape: element.shape,
        type: element.type,
        value: element.value,
      }.compact

      append_or_merge_variant(data, tag)
    end

    private

    def build_element
      raise NotImplementedError, "#{self.class} must implement #build_element"
    end

    def append_or_merge_variant(data, tag)
      if tag && (index = @variants.find_index { |variant| variant[:tag] == tag })
        existing = @variants[index]
        merge_variant_shapes(existing, data[:shape]) if data[:shape] && existing[:shape]
        data.delete(:shape) if data[:shape] && existing[:shape]
        @variants[index] = existing.merge(data)
      else
        @variants << data
      end
    end

    def merge_variant_shapes(existing_variant, new_shape)
      return unless new_shape.respond_to?(:params)

      new_shape.params.each do |name, param_options|
        existing_variant[:shape].params[name] =
          (existing_variant[:shape].params[name] || {}).merge(param_options)
      end
    end

    def validate_tag!(tag)
      raise ArgumentError, 'tag can only be used when union has a discriminator' if tag.present? && @discriminator.nil?

      return unless @discriminator.present? && tag.blank?

      raise ArgumentError, 'tag is required for all variants when union has a discriminator'
    end
  end
end
