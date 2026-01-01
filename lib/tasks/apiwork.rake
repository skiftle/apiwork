# frozen_string_literal: true

namespace :apiwork do
  namespace :docs do
    desc 'Generate API reference documentation from YARD comments'
    task reference: :environment do
      require 'apiwork/reference_generator'
      Apiwork::ReferenceGenerator.run
      puts 'Reference documentation generated in docs/reference/'
    end
  end

  namespace :spec do
    desc 'Write specs to files'
    task write: :environment do
      # Load API definitions
      Dir[Rails.root.join('config/apis/**/*.rb')].sort.each { |f| load f }

      api_path = ENV['API_PATH']
      format = ENV['FORMAT']&.to_sym
      output = ENV['OUTPUT']
      spec_name = ENV['SPEC_NAME']&.to_sym

      unless output
        puts 'Error: OUTPUT required'
        puts ''
        puts 'Usage: rake apiwork:spec:write OUTPUT=path [API_PATH=/api/v1] [SPEC_NAME=openapi] [OPTIONS...]'
        puts ''
        puts 'Examples:'
        puts '  rake apiwork:spec:write OUTPUT=public/specs'
        puts '  rake apiwork:spec:write API_PATH=/api/v1 OUTPUT=public/specs'
        puts '  rake apiwork:spec:write API_PATH=/api/v1 SPEC_NAME=openapi OUTPUT=public/openapi.json'
        puts '  rake apiwork:spec:write SPEC_NAME=openapi FORMAT=yaml OUTPUT=public/openapi.yaml'
        puts '  rake apiwork:spec:write SPEC_NAME=zod KEY_FORMAT=camel OUTPUT=public/specs'
        puts '  rake apiwork:spec:write OUTPUT=public/specs LOCALE=sv'
        puts ''
        puts 'Available specs:'
        puts "  #{Apiwork::Spec.all.join(', ')}"
        puts ''
        puts 'Built-in options (uppercase ENV vars):'
        puts '  FORMAT: json, yaml (only for data specs like openapi)'
        puts '  KEY_FORMAT: keep, camel, underscore'
        puts "  LOCALE: #{I18n.available_locales.join(', ')}"
        puts ''
        puts 'Custom spec options are also supported via ENV vars.'
        exit 1
      end

      custom_options = if spec_name
                         Apiwork::Spec.find(spec_name).extract_options_from_env
                       else
                         {}
                       end

      begin
        Apiwork::Spec::Pipeline.write(
          api_path:,
          format:,
          output:,
          spec_name:,
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

    desc 'Clean generated spec files'
    task clean: :environment do
      output = ENV['OUTPUT']

      unless output
        puts 'Error: OUTPUT required'
        puts ''
        puts 'Usage: rake apiwork:spec:clean OUTPUT=path'
        puts ''
        puts 'Examples:'
        puts '  rake apiwork:spec:clean OUTPUT=public/specs'
        puts '  rake apiwork:spec:clean OUTPUT=public/openapi.json'
        exit 1
      end

      begin
        Apiwork::Spec::Pipeline.clean(output:)
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
