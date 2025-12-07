# frozen_string_literal: true

namespace :docs do
  desc 'Generate documentation examples'
  task generate: :environment do
    require_relative '../example_generator'

    ExampleGenerator.run
  end
end
