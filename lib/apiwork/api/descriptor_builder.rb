# frozen_string_literal: true

module Apiwork
  module API
    class DescriptorBuilder
      def initialize(api_class:)
        @api_class = api_class
      end

      def type(name, &block)
        Contract::Descriptor::Registry.register_type(
          name,
          scope: nil, # Unprefixed - global to API
          api_class: @api_class,
          &block
        )
      end

      def enum(name, values)
        Contract::Descriptor::Registry.register_enum(
          name,
          values,
          scope: nil, # Unprefixed - global to API
          api_class: @api_class
        )
      end
    end
  end
end
