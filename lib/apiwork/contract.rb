# frozen_string_literal: true

module Apiwork
  module Contract
    class << self
      # DOCUMENTATION
      def parse(contract_class, direction, action, data, **options)
        parser = Parser.new(contract_class, direction, action, **options)
        parser.perform(data)
      end

      # DOCUMENTATION
      def reset!
        SchemaRegistry.clear!
      end
    end
  end
end
