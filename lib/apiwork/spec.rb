# frozen_string_literal: true

module Apiwork
  # @api public
  module Spec
    class << self
      # @api public
      # Registers a spec generator.
      #
      # @param klass [Class] a {Spec::Base} subclass with spec_name set
      #
      # @example
      #   Apiwork::Spec.register(GraphqlSpec)
      def register(klass)
        Registry.register(klass)
      end

      def find(spec_name)
        Registry.find(spec_name)
      end

      def all
        Registry.all
      end

      def registered?(spec_name)
        Registry.registered?(spec_name)
      end

      # @api public
      # Generates a spec for an API.
      #
      # @param spec_name [Symbol] the spec name (:openapi, :typescript, :zod)
      # @param api_path [String] the API mount path
      # @param options [Hash] spec-specific options
      # @return [String] the generated spec
      #
      # @example
      #   Apiwork::Spec.generate(:openapi, '/api/v1')
      #   Apiwork::Spec.generate(:typescript, '/api/v1', locale: :sv, key_format: :camel)
      def generate(spec_name, api_path, **options)
        find(spec_name)&.generate(api_path, **options)
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
