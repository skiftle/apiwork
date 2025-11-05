# frozen_string_literal: true

module Apiwork
  module API
    module Routing
      # Builds ActionDispatch::RouteSet from registered APIs
      class Builder
        def build
          # Eager load API classes if in Rails
          eager_load_apis if defined?(::Rails)

          api_classes = Registry.all_classes
          builder_instance = self

          set = ActionDispatch::Routing::RouteSet.new

          set.draw do
            api_classes.each do |api_class|
              next unless api_class.mount_path && api_class.metadata

              # Draw schema endpoints first (outside module namespace)
              if api_class.schemas?
                scope path: api_class.mount_path do
                  api_class.schemas.each do |schema_type, schema_path|
                    get schema_path, to: 'apiwork/schemas#show', defaults: {
                      schema_type: schema_type,
                      api_path: api_class.metadata.path
                    }
                  end
                end
              end

              # Draw resource routes (inside module namespace)
              scope path: api_class.mount_path, module: builder_instance.controller_namespace(api_class) do
                # Draw resources recursively
                builder_instance.draw_resources_in_context(self, api_class.metadata.resources)
              end
            end
          end

          set
        end

        def controller_namespace(api_class)
          api_class.namespaces_parts.map(&:to_s).join('/').underscore
        end

        def draw_resources_in_context(context, resources_hash)
          resources_hash.each do |name, metadata|
            builder_instance = self
            controller_option = extract_controller_option(metadata)

            if metadata[:singular]
              # Singular resource
              context.instance_eval do
                resource name, only: metadata[:actions], controller: controller_option do
                  # Draw member actions
                  unless metadata[:members].empty?
                    member do
                      metadata[:members].each do |action, action_metadata|
                        send(action_metadata[:method], action)
                      end
                    end
                  end

                  # Draw collection actions
                  unless metadata[:collections].empty?
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
            else
              # Plural resources
              context.instance_eval do
                resources name, only: metadata[:actions], controller: controller_option do
                  # Draw member actions
                  unless metadata[:members].empty?
                    member do
                      metadata[:members].each do |action, action_metadata|
                        send(action_metadata[:method], action)
                      end
                    end
                  end

                  # Draw collection actions
                  unless metadata[:collections].empty?
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

        def eager_load_apis
          # Load all API definitions from config/apis
          apis_path = ::Rails.root.join('config', 'apis')
          return unless apis_path.exist?

          Dir[apis_path.join('**', '*.rb')].sort.each do |file|
            load file
          end
        end
      end
    end
  end
end
