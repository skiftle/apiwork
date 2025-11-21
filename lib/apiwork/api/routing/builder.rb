# frozen_string_literal: true

module Apiwork
  module API
    module Routing
      class Builder
        def build
          api_classes = Registry.all
          builder_instance = self

          set = ActionDispatch::Routing::RouteSet.new

          set.draw do
            api_classes.each do |api_class|
              next if api_class.mount_path.blank? || api_class.metadata.blank?

              if api_class.specs?
                scope path: api_class.mount_path do
                  api_class.specs.each do |spec_type, spec_path|
                    get spec_path, to: 'apiwork/specs#show', defaults: {
                      spec_type: spec_type,
                      api_path: api_class.metadata.path
                    }
                  end
                end
              end

              scope path: api_class.mount_path, module: builder_instance.controller_path(api_class) do
                builder_instance.draw_resources_in_context(self, api_class.metadata.resources)
              end
            end
          end

          set
        end

        def controller_path(api_class)
          api_class.namespaces.map(&:to_s).join('/').underscore
        end

        def draw_resources_in_context(context, resources_hash)
          resources_hash.each do |name, metadata|
            builder_instance = self
            resource_method = metadata[:singular] ? :resource : :resources

            options = metadata[:options].slice(:only, :except, :controller).compact

            context.instance_eval do
              send(resource_method, name, **options) do
                if metadata[:members].any?
                  member do
                    metadata[:members].each do |action, action_metadata|
                      send(action_metadata[:method], action)
                    end
                  end
                end

                if metadata[:collections].any?
                  collection do
                    metadata[:collections].each do |action, action_metadata|
                      send(action_metadata[:method], action)
                    end
                  end
                end

                builder_instance.draw_resources_in_context(self, metadata[:resources]) if metadata[:resources].any?
              end
            end
          end
        end
      end
    end
  end
end
