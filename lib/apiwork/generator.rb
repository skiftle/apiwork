# frozen_string_literal: true

module Apiwork
  module Generator
    class << self
      # DOCUMENTATION
      def generate(type, path, **options)
        Generator::Registry.find(type).generate(path: path, **options)
      end

      # DOCUMENTATION
      def register(name, generator_class)
        Generator::Registry.register(name, generator_class)
      end

      # DOCUMENTATION
      def reset!
        Registry.clear!
      end
    end
  end
end
