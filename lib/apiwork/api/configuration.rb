# frozen_string_literal: true

module Apiwork
  module API
    # Configuration DSL for API classes
    #
    # Provides: configure_from_path, spec, mount_at
    module Configuration
      def configure_from_path(path)
        @mount_path = path
        @specs = {}

        # Parse path to namespaces array
        @namespaces_parts = path == '/' ? [:root] : path.split('/').reject(&:empty?).map(&:to_sym)

        # Create metadata with path as source
        @metadata = Metadata.new(path)
        @recorder = Recorder.new(@metadata, @namespaces_parts)

        # Register in Registry
        Registry.register(self)
      end

      def mount_at(path)
        @mount_path = path
      end

      def spec(type, path: nil)
        # Validate that type is registered
        unless Generation::Registry.registered?(type)
          available = Generation::Registry.all.join(', ')
          raise ConfigurationError,
                "Unknown spec generator: :#{type}. " \
                "Available generators: #{available}"
        end

        # Initialize specs hash if needed
        @specs ||= {}

        # Default path if not specified
        path ||= "/.spec/#{type}"

        # Add to specs hash
        @specs[type] = path
      end

      def specs?
        @specs&.any?
      end

      def error_codes(*codes)
        @metadata.error_codes = codes.flatten.map(&:to_i).uniq.sort
      end
    end
  end
end
