# frozen_string_literal: true

module Apiwork
  module Generator
    module Pipeline
      module_function

      def generate(api_path:, format:, **options)
        opts = Options.build(**options)
        generator_class = Registry.find(format)
        generator_class.generate(path: api_path, **opts)
      end

      def write(output:, api_path: nil, format: nil, **options)
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

      def clean(output:)
        raise ArgumentError, 'output path required' unless output

        Writer.clean(output: output)
      end

      def find_api(api_path)
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
      private :find_api

      def find_all_apis
        API::Registry.all.select(&:metadata)
      end
      private :find_all_apis

      def generate_file(api_class:, format:, output:, options:)
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
      private :generate_file
    end
  end
end
