# frozen_string_literal: true

module Apiwork
  module Adapter
    class << self
      delegate :register, :find, :registered?, :all, to: Registry

      def resolve(name)
        Registry.find(name)
      end

      def reset!
        Registry.clear!
        Contract::SchemaRegistry.clear!
      end
    end
  end
end
