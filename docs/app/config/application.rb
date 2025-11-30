# frozen_string_literal: true

require_relative 'boot'
require 'rails/all'

Bundler.require(*Rails.groups)

module Playground
  class Application < Rails::Application
    config.load_defaults 8.0
    config.eager_load = false
    config.autoload_paths << Rails.root.join('app/schemas')
    config.autoload_paths << Rails.root.join('app/contracts')
  end
end
