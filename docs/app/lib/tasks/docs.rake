# frozen_string_literal: true

namespace :docs do
  desc 'Generate all documentation example files from playground APIs'
  task generate: :environment do
    require_relative '../docs/example_generator'

    Docs::ExampleGenerator.run
  end
end
