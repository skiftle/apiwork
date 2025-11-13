# frozen_string_literal: true

module Apiwork
  module Generation
    # Registry for spec generators
    # Allows registration and lookup of generator classes
    class Registry
      class GeneratorNotFound < StandardError; end

      class << self
        # Get all registered generators
        #
        # @return [Hash<Symbol, Class>] Hash of generator name => generator class
        def generators
          @generators ||= {}
        end

        # Register a generator
        #
        # @param name [Symbol] Generator name (e.g., :openapi, :zod)
        # @param generator_class [Class] Generator class (must inherit from Generators::Base)
        # @raise [ArgumentError] if generator doesn't inherit from Generators::Base
        def register(name, generator_class)
          raise ArgumentError, 'Generator must inherit from Apiwork::Generation::Generators::Base' unless generator_class < Generators::Base

          generators[name.to_sym] = generator_class
        end

        # Lookup generator by name
        #
        # @param name [Symbol, String] Generator name
        # @return [Class] Generator class
        # @raise [GeneratorNotFound] if generator not registered
        def [](name)
          generators[name.to_sym] or raise GeneratorNotFound, "Generator :#{name} not registered. " \
                                                               "Available generators: #{all.join(', ')}"
        end

        # Check if generator is registered
        #
        # @param name [Symbol, String] Generator name
        # @return [Boolean]
        def registered?(name)
          generators.key?(name.to_sym)
        end

        # Get all registered generator names
        #
        # @return [Array<Symbol>] Array of generator names
        def all
          generators.keys
        end

        # Clear all registered generators (useful for testing)
        def clear!
          @generators = {}
        end
      end
    end
  end
end
