# frozen_string_literal: true

module Apiwork
  class Engine < ::Rails::Engine
    isolate_namespace Apiwork
    engine_name 'apiwork'

    rake_tasks do
      load File.expand_path('../tasks/apiwork.rake', __dir__)
    end

    initializer 'apiwork.i18n' do
      config.i18n.load_path += Dir[File.expand_path('../../config/locales/**/*.yml', __dir__)]
    end

    config.to_prepare do
      Apiwork.prepare!
    end
  end
end
