# frozen_string_literal: true

module Apiwork
  module Controller
    module Query
      extend ActiveSupport::Concern

      def query(scope, resource_class_name: nil)
        resource_class = if resource_class_name
          resource_class_name.constantize
        else
          namespace = self.class.name.deconstantize
          Apiwork::Resource::Resolver.from_scope(scope, namespace:)
        end

        result = resource_class.query(scope, action_params)

        # Build pagination metadata if pagination params present
        if action_params.key?(:page)
          @pagination_meta = resource_class.build_meta(result)
        end

        result
      end

      def pagination_meta
        @pagination_meta
      end
    end
  end
end
