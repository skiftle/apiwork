# frozen_string_literal: true

module Apiwork
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('templates/install', __dir__)

      desc 'Creates the Apiwork directory structure'

      def create_application_contract
        template 'application_contract.rb.tt', 'app/contracts/application_contract.rb'
      end

      def create_application_representation
        template 'application_representation.rb.tt', 'app/representations/application_representation.rb'
      end

      def create_apis_directory
        empty_directory 'config/apis'
      end

      def add_route
        route "mount Apiwork => '/'"
      end
    end
  end
end
