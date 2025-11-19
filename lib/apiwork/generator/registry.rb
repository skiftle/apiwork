# frozen_string_literal: true

require 'concurrent/map'

module Apiwork
  module Generator
    # Registry for managing available generators
    #
    # Usage:
    #   Registry.register(:zod, Generator::Zod)
    #   generator_class = Registry.find(:zod)
    #
    # Thread-safety: Lock-free using Concurrent::Map (atomic operations)
    class Registry
      class GeneratorNotFound < StandardError; end

      class << self
        def generators
          @generators ||= Concurrent::Map.new
        end

        def register(name, generator_class)
          raise ArgumentError, 'Generator must inherit from Apiwork::Generator::Base' unless generator_class < Base

          generators[name.to_sym] = generator_class
        end

        def find(name)
          generators[name.to_sym] or raise GeneratorNotFound, "Generator :#{name} not registered. " \
                                                               "Available generators: #{all.join(', ')}"
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
