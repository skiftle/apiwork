# frozen_string_literal: true

module Apiwork
  module Spec
    class << self
      delegate :register, :find, to: Registry

      def generate(name, path, **options)
        find(name)&.generate(path: path, **options)
      end

      def reset!
        Registry.clear!
      end
    end
  end
end
