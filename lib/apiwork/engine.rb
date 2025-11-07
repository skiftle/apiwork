# frozen_string_literal: true

module Apiwork
  class Engine < ::Rails::Engine
    isolate_namespace Apiwork
    engine_name 'apiwork'

    # Tell Rails autoloaders to ignore lib/apiwork/** since we manage it with our own Zeitwerk loader
    # This prevents double-loading and ensures our gem's loader is authoritative
    initializer 'apiwork.ignore_lib', before: :set_autoload_paths do
      Rails.autoloaders.each do |autoloader|
        autoloader.ignore(File.expand_path('..', __dir__))
      end
    end

    # Load rake tasks
    rake_tasks do
      load File.expand_path('../tasks/apiwork.rake', __dir__)
    end

    # Configure default settings
    initializer 'apiwork.configure' do
      Apiwork.configure do |config|
        config.default_page_size = 20
        config.maximum_page_size = 200
      end
    end
  end
end
