# frozen_string_literal: true

module Apiwork
  module API
    # @api private
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
                api_class.specs.each do |spec_type|
                  get api_class.spec_path(spec_type), to: 'apiwork/specs#show', defaults: {
                    spec_type: spec_type,
                    api_path: api_class.metadata.path
                  }
                end
              end
            end

            controller_path = api_class.namespaces.map(&:to_s).join('/').underscore
            scope path: api_class.mount_path, module: controller_path do
              router_instance.draw_resources_in_context(self, api_class.metadata.resources)
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

      def draw_resources_in_context(context, resources_hash)
        resources_hash.each do |name, metadata|
          resource_method = metadata[:singular] ? :resource : :resources
          options = metadata[:options].slice(:only, :except, :controller).compact
          router_instance = self

          context.instance_eval do
            send(resource_method, name, **options) do
              if metadata[:members].any?
                member do
                  metadata[:members].each { |action, meta| send(meta[:method], action) }
                end
              end

              if metadata[:collections].any?
                collection do
                  metadata[:collections].each { |action, meta| send(meta[:method], action) }
                end
              end

              router_instance.draw_resources_in_context(self, metadata[:resources])
            end
          end
        end
      end
    end
  end
end
