# frozen_string_literal: true

module Apiwork
  module Adapter
    class DescriptorBuilder
      attr_reader :api_class,
                  :contract_class

      def initialize(api_class:, contract_class:)
        @api_class = api_class
        @contract_class = contract_class
      end

      def type(name, scope: nil, &block)
        Descriptor.register_type(name, scope: scope || contract_class, api_class: api_class, &block)
      end

      def enum(name, values, scope: nil)
        Descriptor.register_enum(name, values, scope: scope || contract_class, api_class: api_class)
      end

      def params(&block)
        ParamsBuilder.new(self).instance_eval(&block)
      end

      class ParamsBuilder
        def initialize(builder)
          @builder = builder
        end

        def type(name, scope: nil, &block)
          @builder.type(name, scope: scope, &block)
        end

        def enum(name, values, scope: nil)
          @builder.enum(name, values, scope: scope)
        end
      end
    end
  end
end
