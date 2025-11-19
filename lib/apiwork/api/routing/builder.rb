# frozen_string_literal: true

module Apiwork
  module API
    module Routing
      # Builds ActionDispatch::RouteSet from registered APIs
      class Builder
        def build
          # APIs are already loaded by Engine.to_prepare
          # Don't reload them here to avoid duplicate loading issues

          api_classes = Registry.all
          builder_instance = self

          set = ActionDispatch::Routing::RouteSet.new

          set.draw do
            api_classes.each do |api_class|
              next if api_class.mount_path.blank? || api_class.metadata.blank?

              # Draw spec endpoints first (outside module namespace)
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

              # Draw resource routes (inside module namespace)
              scope path: api_class.mount_path, module: builder_instance.controller_path(api_class) do
                # Draw resources recursively
                builder_instance.draw_resources_in_context(self, api_class.metadata.resources)
              end
            end
          end

          set
        end

        def controller_path(api_class)
          api_class.namespaces_parts.map(&:to_s).join('/').underscore
        end

        def draw_resources_in_context(context, resources_hash)
          resources_hash.each do |name, metadata|
            builder_instance = self
            controller_option = extract_controller_option(metadata)
            resource_method = metadata[:singular] ? :resource : :resources

            context.instance_eval do
              send(resource_method, name, only: metadata[:only], controller: controller_option) do
                # Draw member actions
                if metadata[:members].any?
                  member do
                    metadata[:members].each do |action, action_metadata|
                      send(action_metadata[:method], action)
                    end
                  end
                end

                # Draw collection actions
                if metadata[:collections].any?
                  collection do
                    metadata[:collections].each do |action, action_metadata|
                      send(action_metadata[:method], action)
                    end
                  end
                end

                # Draw nested resources INSIDE this block
                builder_instance.draw_resources_in_context(self, metadata[:resources]) if metadata[:resources].any?
              end
            end
          end
        end

        private

        def extract_controller_option(metadata)
          return nil unless metadata[:controller_class_name]

          # Convert 'Api::V1::ArticlesController' → 'articles'
          metadata[:controller_class_name]
            .split('::').last
            .sub(/Controller$/, '')
            .underscore
        end
      end
    end
  end
end
