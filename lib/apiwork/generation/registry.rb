# frozen_string_literal: true

module Apiwork
  module Generation
    class Registry
      class GeneratorNotFound < StandardError; end

      class << self
        def generators
          @generators ||= {}
        end

        def register(name, generator_class)
          raise ArgumentError, 'Generator must inherit from Apiwork::Generation::Generators::Base' unless generator_class < Generators::Base

          generators[name.to_sym] = generator_class
        end

        def [](name)
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
          @generators = {}
        end
      end
    end
  end
end
