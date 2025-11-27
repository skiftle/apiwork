# frozen_string_literal: true

require 'concurrent/map'

module Apiwork
  module Generator
    class Registry
      class << self
        def generators
          @generators ||= Concurrent::Map.new
        end

        def register(generator_class)
          raise ArgumentError, 'Generator must inherit from Apiwork::Generator::Base' unless generator_class < Base
          raise ArgumentError, "Generator #{generator_class} must define an identifier" unless generator_class.identifier

          generators[generator_class.identifier] = generator_class
        end

        def find(name)
          key = name.to_sym
          generators.fetch(key) { raise KeyError.new("Generator :#{key} not found. Available: #{all.join(', ')}", key:, receiver: generators) }
        end

        def registered?(name)
          generators.key?(name.to_sym)
        end

        def all
          generators.keys
        end

        def clear!
          @generators = Concurrent::Map.new
        end
      end
    end
  end
end
