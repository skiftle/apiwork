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
            next if api_class.path.blank? || api_class.structure.blank?

            if api_class.specs?
              scope path: api_class.path do
                api_class.specs.each do |spec_name|
                  get api_class.spec_path(spec_name), to: 'apiwork/specs#show', defaults: {
                    spec_name: spec_name,
                    api_path: api_class.path
                  }
                end
              end
            end

            controller_path = api_class.structure.namespaces.map(&:to_s).join('/').underscore
            scope path: api_class.path, module: controller_path do
              router_instance.draw_resources_in_context(self, api_class.structure.resources, api_class)
            end

            scope path: api_class.path do
              match '*unmatched',
                    to: 'apiwork/errors#not_found',
                    via: :all
            end
          end
        end

        set
      end

      def draw_resources_in_context(context, resources_hash, api_class)
        resources_hash.each_value do |resource|
          resource_method = resource.singular ? :resource : :resources
          options = resource.options.slice(:only, :except, :controller).compact

          path_option = resource.options[:path] || api_class.transform_path_segment(resource.name)
          options[:path] = path_option unless path_option == resource.name.to_s

          router_instance = self

          context.instance_eval do
            send(resource_method, resource.name, **options) do
              if resource.member_actions.any?
                member do
                  resource.member_actions.each_value do |action|
                    action_path = api_class.transform_path_segment(action.name)
                    if action_path == action.name.to_s
                      send(action.method, action.name)
                    else
                      send(action.method, action.name, path: action_path)
                    end
                  end
                end
              end

              if resource.collection_actions.any?
                collection do
                  resource.collection_actions.each_value do |action|
                    action_path = api_class.transform_path_segment(action.name)
                    if action_path == action.name.to_s
                      send(action.method, action.name)
                    else
                      send(action.method, action.name, path: action_path)
                    end
                  end
                end
              end

              router_instance.draw_resources_in_context(self, resource.resources, api_class)
            end
          end
        end
      end
    end
  end
end
