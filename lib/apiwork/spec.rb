# frozen_string_literal: true

module Apiwork
  module Spec
    class << self
      delegate :register, :find, :registered?, :all, to: Registry

      def generate(name, path, **options)
        Registry.find(name)&.generate(path: path, **options)
      end

      def reset!
        Registry.clear!
      end
    end
  end
end
