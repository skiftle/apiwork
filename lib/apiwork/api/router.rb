# frozen_string_literal: true

module Apiwork
  module API
    class Router
      def draw
        api_classes = Registry.all
        router_instance = self

        set = ActionDispatch::Routing::RouteSet.new

        set.draw do
          api_classes.each do |api_class|
            next if api_class.mount_path.blank? || api_class.metadata.blank?

            if api_class.specs?
              scope path: api_class.mount_path do
                api_class.specs.each do |spec_name|
                  get api_class.spec_path(spec_name), to: 'apiwork/specs#show', defaults: {
                    spec_name: spec_name,
                    api_path: api_class.metadata.path
                  }
                end
              end
            end

            controller_path = api_class.namespaces.map(&:to_s).join('/').underscore
            scope path: api_class.mount_path, module: controller_path do
              router_instance.draw_resources_in_context(self, api_class.metadata.resources, api_class)
            end

            scope path: api_class.mount_path do
              match '*unmatched',
                    to: 'apiwork/errors#not_found',
                    via: :all
            end
          end
        end

        set
      end

      def draw_resources_in_context(context, resources_hash, api_class)
        resources_hash.each do |name, metadata|
          resource_method = metadata[:singular] ? :resource : :resources
          options = metadata[:options].slice(:only, :except, :controller).compact

          path_option = metadata.dig(:options, :path) ||
                        api_class.transform_path_segment(name)
          options[:path] = path_option unless path_option == name.to_s

          router_instance = self

          context.instance_eval do
            send(resource_method, name, **options) do
              if metadata[:members].any?
                member do
                  metadata[:members].each do |action, meta|
                    action_path = api_class.transform_path_segment(action)
                    if action_path == action.to_s
                      send(meta[:method], action)
                    else
                      send(meta[:method], action, path: action_path)
                    end
                  end
                end
              end

              if metadata[:collections].any?
                collection do
                  metadata[:collections].each do |action, meta|
                    action_path = api_class.transform_path_segment(action)
                    if action_path == action.to_s
                      send(meta[:method], action)
                    else
                      send(meta[:method], action, path: action_path)
                    end
                  end
                end
              end

              router_instance.draw_resources_in_context(self, metadata[:resources], api_class)
            end
          end
        end
      end
    end
  end
end
