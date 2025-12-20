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
      output = ENV['OUTPUT']
      identifier = ENV['IDENTIFIER']&.to_sym

      unless output
        puts 'Error: OUTPUT required'
        puts ''
        puts 'Usage: rake apiwork:spec:write OUTPUT=path [API_PATH=/api/v1] [IDENTIFIER=openapi] [OPTIONS...]'
        puts ''
        puts 'Examples:'
        puts '  rake apiwork:spec:write OUTPUT=public/specs'
        puts '  rake apiwork:spec:write API_PATH=/api/v1 OUTPUT=public/specs'
        puts '  rake apiwork:spec:write API_PATH=/api/v1 IDENTIFIER=openapi OUTPUT=public/openapi.json'
        puts '  rake apiwork:spec:write IDENTIFIER=zod KEY_FORMAT=camel OUTPUT=public/specs'
        puts '  rake apiwork:spec:write OUTPUT=public/specs LOCALE=sv'
        puts ''
        puts 'Available identifiers:'
        puts "  #{Apiwork::Spec.all.join(', ')}"
        puts ''
        puts 'Built-in options (uppercase ENV vars):'
        puts '  KEY_FORMAT: keep, camel, underscore'
        puts "  LOCALE: #{I18n.available_locales.join(', ')}"
        puts ''
        puts 'Custom spec options are also supported via ENV vars.'
        exit 1
      end

      custom_options = if identifier
                         Apiwork::Spec.find(identifier).extract_options_from_env
                       else
                         {}
                       end

      begin
        Apiwork::Spec::Pipeline.write(
          api_path: api_path,
          output: output,
          identifier: identifier,
          **custom_options
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
        Apiwork::Spec::Pipeline.clean(output: output)
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
