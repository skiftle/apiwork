# frozen_string_literal: true

module Apiwork
  module Controller
    module ActionParams
      extend ActiveSupport::Concern

      def action_params(options = {})
        case action_name.to_sym
        when :create, :update
          # Priority: contract_class_name > resource_class_name > default
          resource = if options[:contract_class_name]
            # Get resource from contract
            contract = options[:contract_class_name].constantize
            action_def = contract.action_definition(action_name.to_sym)
            action_def.contract_class.resource_class
          elsif options[:resource_class_name]
            options[:resource_class_name].constantize
          else
            Resource::Resolver.from_controller(self.class)
          end

          validated_request.params[resource.root_key.singular.to_sym] || {}
        else
          validated_request.params
        end
      end
    end
  end
end
