# frozen_string_literal: true

module Apiwork
  module Export
    class Pipeline
      class << self
        def generate(export_name, api_base_path, format: nil, key_format: nil, locale: nil, version: nil)
          Export.generate(export_name, api_base_path, format:, key_format:, locale:, version:)
        end

        def write(api_base_path: nil, export_name: nil, format: nil, key_format: nil, locale: nil, output:, version: nil)
          raise ArgumentError, 'output path required' unless output

          if Writer.file_path?(output) && (api_base_path.nil? || export_name.nil?)
            raise ArgumentError,
                  'api_base_path and export_name required when output is a file'
          end

          api_classes = api_base_path ? [find_api_class(api_base_path)] : API.values

          start_time = Time.zone.now
          count = 0

          Rails.logger.debug 'Generating artifacts...'

          api_classes.each do |api_class|
            available_exports = export_name ? [export_name.to_sym] : api_class.export_configs.keys

            available_exports.each do |name|
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

          Rails.logger.debug "\nGenerated #{count} file#{count == 1 ? '' : 's'} in #{(Time.zone.now - start_time).round(2)}s"

          count
        end

        def clean(output:)
          raise ArgumentError, 'output path required' unless output

          Writer.clean(output:)
        end

        private

        def find_api_class(api_base_path)
          API.find!(api_base_path)
        end

        def generate_file(api_class:, export_name:, format:, key_format:, locale:, output:, version:)
          api_base_path = api_class.base_path

          options = { format:, key_format:, locale:, version: }.compact
          options_label = options.any? ? " (#{options.map { |key, value| "#{key}: #{value}" }.join(', ')})" : ''
          Rails.logger.debug "  ✓ #{api_base_path} to #{export_name}#{options_label}"

          content = generate(export_name, api_base_path, format:, key_format:, locale:, version:)
          export_class = Registry.find!(export_name)
          extension = export_class.file_extension_for(format:)

          file_path = Writer.write(
            api_base_path:,
            content:,
            export_name:,
            extension:,
            output:,
          )

          Rails.logger.debug "    to #{file_path}"
          1
        end
      end
    end
  end
end
