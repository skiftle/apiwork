# frozen_string_literal: true

module Apiwork
  # @api public
  module Spec
    class << self
      # @api public
      # Registers a spec generator.
      #
      # @param klass [Class] the spec class (subclass of Spec::Base with register_as)
      #
      # @example
      #   Apiwork::Spec.register(GraphqlSpec)
      def register(klass)
        Registry.register(klass)
      end

      def find(identifier)
        Registry.find(identifier)
      end

      def all
        Registry.all
      end

      def registered?(identifier)
        Registry.registered?(identifier)
      end

      # @api public
      # Generates a spec for an API.
      #
      # @param identifier [Symbol] the spec identifier (:openapi, :typescript, :zod)
      # @param api_path [String] the API mount path
      # @param options [Hash] spec-specific options
      # @return [String] the generated spec
      #
      # @example
      #   Apiwork::Spec.generate(:openapi, '/api/v1')
      #   Apiwork::Spec.generate(:typescript, '/api/v1', namespace: 'Api')
      def generate(identifier, api_path, **options)
        find(identifier)&.generate(api_path, **options)
      end

      # @api public
      # Clears all registered specs. Intended for test cleanup.
      #
      # @example
      #   Apiwork::Spec.reset!
      def reset!
        Registry.clear!
      end
    end
  end
end
