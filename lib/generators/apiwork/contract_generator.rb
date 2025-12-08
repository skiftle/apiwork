# frozen_string_literal: true

module Apiwork
  module Generators
    class ContractGenerator < Rails::Generators::NamedBase
      source_root File.expand_path('templates/contract', __dir__)

      desc 'Creates an Apiwork contract'

      def create_contract
        template 'contract.rb.tt', contract_path
      end

      private

      def contract_path
        File.join('app/contracts', class_path, "#{file_name}_contract.rb")
      end

      def parent_class_name
        'ApplicationContract'
      end
    end
  end
end
