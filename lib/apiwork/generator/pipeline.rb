# frozen_string_literal: true

module Apiwork
  module Generator
    # Pipeline orchestrates the generation and writing of API artifacts
    #
    # Supports both in-memory generation (for HTTP responses) and
    # filesystem generation (for build-time artifact creation).
    #
    # Usage:
    #   # Generate in memory (returns content)
    #   Pipeline.generate(api_path: '/api/v1', format: :zod, key_transform: :camel)
    #
    #   # Write to filesystem
    #   Pipeline.write(output: 'generated/', format: :zod)
    #
    #   # Clean generated files
    #   Pipeline.clean(output: 'generated/')
    #
    class Pipeline
      # Generate artifact in memory
      #
      # @param api_path [String] API path to generate for
      # @param format [Symbol] Generator format (:zod, :typescript, :openapi)
      # @param options [Hash] Generator options (key_transform, version, etc.)
      # @return [String, Hash] Generated content
      def self.generate(api_path:, format:, **options)
        opts = Options.build(**options)
        generator_class = Registry.find(format)
        generator_class.generate(path: api_path, **opts)
      end

      # Write artifacts to filesystem
      #
      # @param output [String] Output path (file or directory)
      # @param api_path [String, nil] Specific API path (nil for all APIs)
      # @param format [Symbol, nil] Specific format (nil for all registered formats)
      # @param options [Hash] Generator options
      # @return [Integer] Number of files generated
      def self.write(output:, api_path: nil, format: nil, **options)
        raise ArgumentError, 'output path required' unless output
        raise ArgumentError, 'api_path and format required when output is a file' if Writer.file_path?(output) && (api_path.nil? || format.nil?)

        apis = api_path ? [find_api(api_path)] : find_all_apis
        formats = format ? [format] : Registry.all

        start_time = Time.zone.now
        count = 0

        Rails.logger.debug 'Generating artifacts...'

        apis.each do |api_class|
          formats.each do |fmt|
            count += generate_file(
              api_class: api_class,
              format: fmt,
              output: output,
              options: options
            )
          end
        end

        elapsed = Time.zone.now - start_time
        Rails.logger.debug "\nGenerated #{count} file#{count == 1 ? '' : 's'} in #{elapsed.round(2)}s"

        count
      end

      # Clean generated artifacts from filesystem
      #
      # @param output [String] Output path to clean
      def self.clean(output:)
        raise ArgumentError, 'output path required' unless output

        Writer.clean(output: output)
      end

      # Find API class by path
      #
      # @param api_path [String] API path
      # @return [Class] API class
      # @raise [ArgumentError] If API not found
      def self.find_api(api_path)
        api_class = API::Registry.all.find do |klass|
          klass.metadata&.path == api_path
        end

        unless api_class
          available = API::Registry.all.map { |k| k.metadata&.path }.compact
          raise ArgumentError,
                "API not found: #{api_path}. Available APIs: #{available.join(', ')}"
        end

        api_class
      end
      private_class_method :find_api

      # Find all registered API classes
      #
      # @return [Array<Class>] API classes with metadata
      def self.find_all_apis
        API::Registry.all.select(&:metadata)
      end
      private_class_method :find_all_apis

      # Generate and write a single file
      #
      # @param api_class [Class] API class
      # @param format [Symbol] Generator format
      # @param output [String] Output path
      # @param options [Hash] Generator options
      # @return [Integer] 1 if successful, 0 if skipped/failed
      def self.generate_file(api_class:, format:, output:, options:)
        api_path = api_class.metadata.path

        unless api_class.specs&.key?(format)
          Rails.logger.debug "  ⊘ Skipping #{api_path} → #{format} (not configured)"
          return 0
        end

        opts_str = options.any? ? " (#{options.map { |k, v| "#{k}: #{v}" }.join(', ')})" : ''
        Rails.logger.debug "  ✓ #{api_path} → #{format}#{opts_str}"

        content = generate(api_path: api_path, format: format, **options)
        generator_class = Registry.find(format)
        extension = generator_class.file_extension

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
      private_class_method :generate_file
    end
  end
end
