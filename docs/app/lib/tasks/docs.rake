# frozen_string_literal: true

namespace :docs do
  desc 'Generate documentation examples'
  task generate: :environment do
    require_relative '../schema_generator'
    require_relative '../example_generator'

    SchemaGenerator.run
    ExampleGenerator.run
  end
end
