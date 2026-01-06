# frozen_string_literal: true

module Apiwork
  module Export
    class Pipeline
      class << self
        def generate(export_name, api_path, format: nil, key_format: nil, locale: nil, version: nil)
          Export.generate(export_name, api_path, format:, key_format:, locale:, version:)
        end

        def write(api_path: nil, export_name: nil, format: nil, key_format: nil, locale: nil, output:, version: nil)
          raise ArgumentError, 'output path required' unless output

          if Writer.file_path?(output) && (api_path.nil? || export_name.nil?)
            raise ArgumentError,
                  'api_path and export_name required when output is a file'
          end

          api_classes = api_path ? [find_api_class(api_path)] : API.all
          export_names = export_name ? [export_name] : Registry.all

          start_time = Time.zone.now
          count = 0

          Rails.logger.debug 'Generating artifacts...'

          api_classes.each do |api_class|
            export_names.each do |name|
              count += generate_file(
                api_class:,
                format:,
                key_format:,
                locale:,
                output:,
                version:,
                export_name: name,
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

        def generate_file(api_class:, export_name:, format:, key_format:, locale:, output:, version:)
          api_path = api_class.path

          unless api_class.exports&.include?(export_name)
            Rails.logger.debug "  ⊘ Skipping #{api_path} → #{export_name} (not configured)"
            return 0
          end

          options = { format:, key_format:, locale:, version: }.compact
          options_label = options.any? ? " (#{options.map { |k, v| "#{k}: #{v}" }.join(', ')})" : ''
          Rails.logger.debug "  ✓ #{api_path} → #{export_name}#{options_label}"

          content = generate(export_name, api_path, format:, key_format:, locale:, version:)
          export = Registry.find(export_name).new(api_path, key_format:, locale:, version:)
          extension = export.file_extension_for(format:)

          file_path = Writer.write(
            api_path:,
            content:,
            export_name:,
            extension:,
            output:,
          )

          Rails.logger.debug "    → #{file_path}"
          1
        end
      end
    end
  end
end
