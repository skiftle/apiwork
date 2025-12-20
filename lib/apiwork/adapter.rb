# frozen_string_literal: true

module Apiwork
  module Adapter
    class << self
      delegate :register, :find, :registered?, :all, to: Registry

      def reset!
        Registry.clear!
      end
    end
  end
end
