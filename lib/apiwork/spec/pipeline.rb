# frozen_string_literal: true

module Apiwork
  module Spec
    class Pipeline
      class << self
        def generate(spec_name, api_path, key_format: nil, locale: nil, version: nil)
          generator_class = Registry.find(spec_name)
          generator_class.generate(api_path, key_format:, locale:, version:)
        end

        def write(api_path: nil, key_format: nil, locale: nil, output:, spec_name: nil, version: nil)
          raise ArgumentError, 'output path required' unless output

          if Writer.file_path?(output) && (api_path.nil? || spec_name.nil?)
            raise ArgumentError,
                  'api_path and spec_name required when output is a file'
          end

          api_classes = api_path ? [find_api_class(api_path)] : API.all
          spec_names = spec_name ? [spec_name] : Registry.all

          start_time = Time.zone.now
          count = 0

          Rails.logger.debug 'Generating artifacts...'

          api_classes.each do |api_class|
            spec_names.each do |name|
              count += generate_file(
                api_class:,
                key_format:,
                locale:,
                output:,
                version:,
                spec_name: name,
              )
            end
          end

          elapsed = Time.zone.now - start_time
          Rails.logger.debug "\nGenerated #{count} file#{count == 1 ? '' : 's'} in #{elapsed.round(2)}s"

          count
        end

        def clean(output:)
          raise ArgumentError, 'output path required' unless output

          Writer.clean(output:)
        end

        private

        def find_api_class(api_path)
          api_class = API.find(api_path)
          return api_class if api_class

          available = API.all.filter_map(&:path)
          raise ArgumentError,
                "API not found: #{api_path}. Available APIs: #{available.join(', ')}"
        end

        def generate_file(api_class:, key_format:, locale:, output:, spec_name:, version:)
          api_path = api_class.path

          unless api_class.specs&.include?(spec_name)
            Rails.logger.debug "  ⊘ Skipping #{api_path} → #{spec_name} (not configured)"
            return 0
          end

          options = { key_format:, locale:, version: }.compact
          options_label = options.any? ? " (#{options.map { |k, v| "#{k}: #{v}" }.join(', ')})" : ''
          Rails.logger.debug "  ✓ #{api_path} → #{spec_name}#{options_label}"

          content = generate(spec_name, api_path, key_format:, locale:, version:)
          generator_class = Registry.find(spec_name)
          extension = generator_class.file_extension

          file_path = Writer.write(
            api_path:,
            content:,
            extension:,
            output:,
            spec_name:,
          )

          Rails.logger.debug "    → #{file_path}"
          1
        end
      end
    end
  end
end
