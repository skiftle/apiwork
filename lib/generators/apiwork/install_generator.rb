# frozen_string_literal: true

module Apiwork
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('templates/install', __dir__)

      desc 'Creates the Apiwork directory structure'

      def create_application_contract
        template 'application_contract.rb.tt', 'app/contracts/application_contract.rb'
      end

      def create_application_schema
        template 'application_schema.rb.tt', 'app/schemas/application_schema.rb'
      end

      def create_apis_directory
        empty_directory 'config/apis'
      end
    end
  end
end
