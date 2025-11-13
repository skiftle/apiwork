# frozen_string_literal: true

module Apiwork
  module Generation
    class Spec
      def self.generate(api_path:, format:, **options)
        opts = Options.build(**options)
        generator_class = Registry[format]
        generator_class.generate(path: api_path, **opts)
      end

      def self.write(output:, api_path: nil, format: nil, **options)
        raise ArgumentError, 'output path required' unless output
        raise ArgumentError, 'api_path and format required when output is a file' if Writer.file_path?(output) && (!api_path || !format)

        apis = api_path ? [find_api(api_path)] : find_all_apis
        formats = format ? [format] : Registry.all

        start_time = Time.zone.now
        count = 0

        Rails.logger.debug 'Generating specs...'

        apis.each do |api_class|
          formats.each do |fmt|
            count += write_spec(
              api_class: api_class,
              format: fmt,
              output: output,
              options: options
            )
          end
        end

        elapsed = Time.zone.now - start_time
        Rails.logger.debug "\nGenerated #{count} spec#{count == 1 ? '' : 's'} in #{elapsed.round(2)}s"

        count
      end

      def self.clean(output:)
        raise ArgumentError, 'output path required' unless output

        Writer.clean(output: output)
      end

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

      def self.find_all_apis
        API::Registry.all_classes.select(&:metadata)
      end
      private_class_method :find_all_apis

      def self.write_spec(api_class:, format:, output:, options:)
        api_path = api_class.metadata.path

        unless api_class.specs&.key?(format)
          Rails.logger.debug "  ⊘ Skipping #{api_path} → #{format} (not configured)"
          return 0
        end

        opts_str = options.any? ? " (#{options.map { |k, v| "#{k}: #{v}" }.join(', ')})" : ''
        Rails.logger.debug "  ✓ #{api_path} → #{format}#{opts_str}"

        content = generate(api_path: api_path, format: format, **options)
        generator_class = Registry[format]
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
      private_class_method :write_spec
    end
  end
end
