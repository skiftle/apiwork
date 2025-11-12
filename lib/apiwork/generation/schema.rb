# frozen_string_literal: true

module Apiwork
  module Generation
    # Unified schema generation
    #
    # Provides two interfaces:
    # 1. generate() - Pure function, returns schema content
    # 2. write()    - Side effects, writes to files
    #
    # @example Generate schema (pure)
    #   schema = Apiwork::Generation::Schema.generate(
    #     api_path: '/api/v1',
    #     format: :openapi,
    #     key_transform: :underscore
    #   )
    #
    # @example Write schemas to files
    #   Apiwork::Generation::Schema.write(
    #     output: 'public/schemas',
    #     key_transform: :underscore
    #   )
    class Schema
      # Generate schema content
      #
      # @param api_path [String] API path (e.g., '/api/v1')
      # @param format [Symbol] Schema format (:openapi, :transport, :zod)
      # @param options [Hash] Generator options (key_transform, builders)
      # @return [String, Hash] Generated schema content
      # @raise [Registry::GeneratorNotFound] if format not registered
      # @raise [ArgumentError] if options invalid
      def self.generate(api_path:, format:, **options)
        # Build and validate options
        opts = Options.build(**options)

        # Lookup generator
        generator_class = Registry[format]

        # Generate schema
        generator_class.generate(api_path, **opts)
      end

      # Write schemas to files
      #
      # @param api_path [String, nil] Specific API or nil for all
      # @param output [String] Output path (file or directory)
      # @param format [Symbol, nil] Specific format or nil for all
      # @param options [Hash] Generator options
      # @return [Integer] Number of schemas generated
      # @raise [ArgumentError] if output missing or invalid combination
      def self.write(output:, api_path: nil, format: nil, **options)
        raise ArgumentError, 'output path required' unless output

        # Validate if single file mode
        raise ArgumentError, 'api_path and format required when output is a file' if Writer.file_path?(output) && (!api_path || !format)

        # Find APIs and formats
        apis = api_path ? [find_api(api_path)] : find_all_apis
        formats = format ? [format] : Registry.all

        # Generate and write
        start_time = Time.zone.now
        count = 0

        Rails.logger.debug 'Generating schemas...'

        apis.each do |api_class|
          formats.each do |fmt|
            count += write_schema(
              api_class: api_class,
              format: fmt,
              output: output,
              options: options
            )
          end
        end

        elapsed = Time.zone.now - start_time
        Rails.logger.debug "\nGenerated #{count} schema#{count == 1 ? '' : 's'} in #{elapsed.round(2)}s"

        count
      end

      # Clean generated files
      #
      # @param output [String] Output path to clean
      # @raise [ArgumentError] if output missing
      def self.clean(output:)
        raise ArgumentError, 'output path required' unless output

        Writer.clean(output: output)
      end

      # Find specific API by path
      #
      # @param api_path [String] API path to find
      # @return [Class] API class
      # @raise [ArgumentError] if API not found
      def self.find_api(api_path)
        api_class = API::Registry.all_classes.find do |klass|
          klass.metadata&.path == api_path
        end

        unless api_class
          available = API::Registry.all_classes.map { |k| k.metadata&.path }.compact
          raise ArgumentError,
                "API not found: #{api_path}. Available APIs: #{available.join(', ')}"
        end

        api_class
      end
      private_class_method :find_api

      # Find all APIs with metadata
      #
      # @return [Array<Class>] API classes
      def self.find_all_apis
        API::Registry.all_classes.select(&:metadata)
      end
      private_class_method :find_all_apis

      # Write a single schema
      #
      # @param api_class [Class] API class
      # @param format [Symbol] Format name
      # @param output [String] Output path
      # @param options [Hash] Generator options
      # @return [Integer] 1 if generated, 0 if skipped
      def self.write_schema(api_class:, format:, output:, options:)
        api_path = api_class.metadata.path

        # Check if schema is configured
        unless api_class.schemas&.key?(format)
          Rails.logger.debug "  ⊘ Skipping #{api_path} → #{format} (not configured)"
          return 0
        end

        # Generate using core generate method
        opts_str = options.any? ? " (#{options.map { |k, v| "#{k}: #{v}" }.join(', ')})" : ''
        Rails.logger.debug "  ✓ #{api_path} → #{format}#{opts_str}"

        content = generate(api_path: api_path, format: format, **options)

        # Get generator metadata
        generator_class = Registry[format]
        extension = generator_class.file_extension

        # Write to file
        file_path = Writer.write(
          content: content,
          output: output,
          api_path: api_path,
          format: format,
          extension: extension
        )

        Rails.logger.debug "    → #{file_path}"
        1
      rescue StandardError => e
        Rails.logger.debug "  ✗ #{api_path} → #{format} (error: #{e.message})"
        0
      end
      private_class_method :write_schema
    end
  end
end
