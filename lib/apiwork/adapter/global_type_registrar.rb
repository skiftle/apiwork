# frozen_string_literal: true

module Apiwork
  module Adapter
    class GlobalTypeRegistrar
      def initialize(api_class)
        @api_class = api_class
      end

      def type(name, &block)
        @api_class.type(name, &block)
      end

      def enum(name, values:)
        @api_class.enum(name, values:)
      end

      def union(name, discriminator: nil, &block)
        @api_class.union(name, discriminator:, &block)
      end
    end
  end
end
