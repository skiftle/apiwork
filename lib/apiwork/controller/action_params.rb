# frozen_string_literal: true

module Apiwork
  module Controller
    module ActionParams
      extend ActiveSupport::Concern

      def action_params(options = {})
        case action_name.to_sym
        when :create, :update
          resource = options[:resource] || Resource::Resolver.from_controller(self.class)
          validated_request.params[resource.root_key.singular.to_sym] || {}
        else
          validated_request.params
        end
      end
    end
  end
end
