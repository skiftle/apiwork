# frozen_string_literal: true

module Apiwork
  module RailsIntegration
    class Engine < ::Rails::Engine
      # This engine provides Apiwork functionality to Rails applications

      # Isolate namespace for proper Rails engine behavior
      isolate_namespace Apiwork

      # Apiwork manages its own autoloading via Zeitwerk in lib/apiwork.rb
      # Don't add lib to Rails autoload paths to avoid conflicts

      initializer 'apiwork.add_autoload_paths', before: :set_autoload_paths do |app|
        app.config.autoload_paths << app.root.join('app/resources')
        app.config.autoload_paths << app.root.join('app/contracts')
      end

      # Load rake tasks
      rake_tasks do
        load File.expand_path('../tasks/apiwork.rake', __dir__)
      end

      # Configure Apiwork on Rails initialization
      initializer 'apiwork.configure' do |_app|
        # Set default configuration
        Apiwork.configure do |config|
          config.default_page_size = 20
          config.maximum_page_size = 200
        end
      end
    end
  end
end
