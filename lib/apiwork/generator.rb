# frozen_string_literal: true

module Apiwork
  module Generator
    class << self
      def generate(type, path, **options)
        Generator::Registry.find(type).generate(path: path, **options)
      end

      def register(name, generator_class)
        Generator::Registry.register(name, generator_class)
      end
    end
  end
end
