# frozen_string_literal: true

module Apiwork
  module API
    class Router
      def draw
        api_classes = Registry.values
        router = self

        set = ActionDispatch::Routing::RouteSet.new

        set.draw do
          api_classes.each do |api_class|
            next if api_class.path.blank? || api_class.structure.blank?

            if api_class.export_configs.any?
              scope path: api_class.path do
                api_class.export_configs.each do |export_name, export_config|
                  next unless case export_config.endpoint.mode
                              when :always then true
                              when :never then false
                              when :auto then Rails.env.development?
                              end

                  get export_config.endpoint.path || "/.#{export_name}",
                      defaults: { export_name:, api_path: api_class.path },
                      to: 'apiwork/exports#show'
                end
              end
            end

            scope module: api_class.structure.namespaces.map(&:to_s).join('/').underscore,
                  path: api_class.path do
              router.draw_resources(self, api_class.structure.resources, api_class)
            end

            scope path: api_class.path do
              match '*unmatched', to: 'apiwork/errors#not_found', via: :all
            end
          end
        end

        set
      end

      def draw_resources(context, resources_hash, api_class)
        resources_hash.each_value do |resource|
          resource_method = resource.singular ? :resource : :resources
          options = {
            constraints: resource.constraints,
            controller: resource.controller,
            defaults: resource.defaults,
            except: resource.except,
            only: resource.only,
            param: resource.param,
          }.compact

          path_option = resource.path || api_class.transform_path_segment(resource.name)
          options[:path] = path_option unless path_option == resource.name.to_s

          router = self

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

              router.draw_resources(self, resource.resources, api_class)
            end
          end
        end
      end
    end
  end
end
