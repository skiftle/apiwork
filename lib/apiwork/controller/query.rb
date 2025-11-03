# frozen_string_literal: true

module Apiwork
  module Controller
    module Query
      extend ActiveSupport::Concern

      def query(scope)
        namespace = self.class.name.deconstantize
        resource_class = Apiwork::Resource::Resolver.from_scope(scope, namespace:)
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
