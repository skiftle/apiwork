# frozen_string_literal: true

module Apiwork
  module Generator
    class << self
      # DOCUMENTATION
      def generate(name, path, **options)
        Registry.find(name)&.generate(path: path, **options)
      end

      # DOCUMENTATION
      def register(name, generator_class)
        Registry.register(name, generator_class)
      end

      # DOCUMENTATION
      def reset!
        Registry.clear!
      end
    end
  end
end
