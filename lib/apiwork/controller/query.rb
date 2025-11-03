# frozen_string_literal: true

module Apiwork
  module Controller
    module Query
      extend ActiveSupport::Concern

      def query(scope)
        namespace = self.class.name.deconstantize
        resource_class = Apiwork::Resource::Resolver.from_scope(scope, namespace:)
        resource_class.query(scope, action_params)
      end
    end
  end
end
