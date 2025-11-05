# frozen_string_literal: true

namespace :apiwork do
  namespace :schema do
    desc 'Write schemas to files'
    task write: :environment do
      # Load API definitions
      Dir[Rails.root.join('config/apis/**/*.rb')].sort.each { |f| load f }

      api_path = ENV['API_PATH']
      output = ENV['OUTPUT']
      format = ENV['FORMAT']&.to_sym
      key_transform = ENV['KEY_TRANSFORM']&.to_sym

      unless output
        puts 'Error: OUTPUT required'
        puts ''
        puts 'Usage: rake apiwork:schema:write OUTPUT=path [API_PATH=/api/v1] [FORMAT=openapi] [KEY_TRANSFORM=underscore]'
        puts ''
        puts 'Examples:'
        puts '  rake apiwork:schema:write OUTPUT=public/schemas'
        puts '  rake apiwork:schema:write API_PATH=/api/v1 OUTPUT=public/schemas'
        puts '  rake apiwork:schema:write API_PATH=/api/v1 FORMAT=openapi OUTPUT=public/openapi.json'
        puts '  rake apiwork:schema:write FORMAT=transport KEY_TRANSFORM=underscore OUTPUT=public/schemas'
        puts ''
        puts 'Available formats:'
        puts "  #{Apiwork::Generation::Registry.all.join(', ')}"
        puts ''
        puts 'Available key transforms:'
        puts '  camelize_lower, camelize_upper, underscore, dasherize, none'
        exit 1
      end

      begin
        Apiwork::Generation::Schema.write(
          api_path: api_path,
          output: output,
          format: format,
          key_transform: key_transform
        )
      rescue ArgumentError => e
        puts "Error: #{e.message}"
        exit 1
      rescue StandardError => e
        puts "Error: #{e.message}"
        puts e.backtrace.first(5).join("\n") if ENV['VERBOSE']
        exit 1
      end
    end

    desc 'Clean generated schema files'
    task clean: :environment do
      output = ENV['OUTPUT']

      unless output
        puts 'Error: OUTPUT required'
        puts ''
        puts 'Usage: rake apiwork:schema:clean OUTPUT=path'
        puts ''
        puts 'Examples:'
        puts '  rake apiwork:schema:clean OUTPUT=public/schemas'
        puts '  rake apiwork:schema:clean OUTPUT=public/openapi.json'
        exit 1
      end

      begin
        Apiwork::Generation::Schema.clean(output: output)
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
