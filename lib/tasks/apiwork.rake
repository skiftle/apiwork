# frozen_string_literal: true

namespace :apiwork do
  namespace :docs do
    desc 'Generate API reference documentation from YARD comments'
    task reference: :environment do
      require 'apiwork/reference_generator'
      Apiwork::ReferenceGenerator.generate
      puts 'Reference documentation generated in docs/reference/'
    end
  end

  namespace :export do
    desc 'Write exports to files'
    task write: :environment do
      # Load API definitions
      Dir[Rails.root.join('config/apis/**/*.rb')].sort.each { |file| load file }

      api_base_path = ENV['API_PATH']
      export_name = ENV['EXPORT_NAME']&.to_sym
      format = ENV['FORMAT']&.to_sym
      output = ENV['OUTPUT']

      unless output
        puts 'Error: OUTPUT required'
        puts ''
        puts 'Usage: rake apiwork:export:write OUTPUT=path [API_PATH=/api/v1] [EXPORT_NAME=openapi] [OPTIONS...]'
        puts ''
        puts 'Examples:'
        puts '  rake apiwork:export:write OUTPUT=public/exports'
        puts '  rake apiwork:export:write API_PATH=/api/v1 OUTPUT=public/exports'
        puts '  rake apiwork:export:write API_PATH=/api/v1 EXPORT_NAME=openapi OUTPUT=public/openapi.json'
        puts '  rake apiwork:export:write EXPORT_NAME=openapi FORMAT=yaml OUTPUT=public/openapi.yaml'
        puts '  rake apiwork:export:write EXPORT_NAME=zod KEY_FORMAT=camel OUTPUT=public/exports'
        puts '  rake apiwork:export:write OUTPUT=public/exports LOCALE=sv'
        puts ''
        puts 'Available exports:'
        puts "  #{Apiwork::Export.keys.join(', ')}"
        puts ''
        puts 'Built-in options (uppercase ENV vars):'
        puts '  FORMAT: json, yaml (only for data exports like openapi)'
        puts '  KEY_FORMAT: keep, camel, underscore'
        puts "  LOCALE: #{I18n.available_locales.join(', ')}"
        puts ''
        puts 'Custom export options are also supported via ENV vars.'
        exit 1
      end

      custom_options = if export_name
                         Apiwork::Export.find!(export_name).extract_options_from_env
                       else
                         {}
                       end

      begin
        Apiwork::Export::Pipeline.write(
          api_base_path:,
          export_name:,
          format:,
          output:,
          **custom_options,
        )
      rescue ArgumentError => e
        puts "Error: #{e.message}"
        exit 1
      rescue Apiwork::ConfigurationError => e
        puts "Error: #{e.message}"
        exit 1
      rescue StandardError => e
        puts "Error: #{e.message}"
        puts e.backtrace.first(5).join("\n") if ENV['VERBOSE']
        exit 1
      end
    end

    desc 'Clean generated export files'
    task clean: :environment do
      output = ENV['OUTPUT']

      unless output
        puts 'Error: OUTPUT required'
        puts ''
        puts 'Usage: rake apiwork:export:clean OUTPUT=path'
        puts ''
        puts 'Examples:'
        puts '  rake apiwork:export:clean OUTPUT=public/exports'
        puts '  rake apiwork:export:clean OUTPUT=public/openapi.json'
        exit 1
      end

      begin
        Apiwork::Export::Pipeline.clean(output:)
      rescue ArgumentError => e
        puts "Error: #{e.message}"
        exit 1
      rescue StandardError => e
        puts "Error: #{e.message}"
        exit 1
      end
    end
  end
end
