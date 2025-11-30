# frozen_string_literal: true

namespace :examples do
  desc 'Generate examples from app'
  task generate: :environment do
    require_relative '../example_generator'

    ExampleGenerator.run
  end
end
