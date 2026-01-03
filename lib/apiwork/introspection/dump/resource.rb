# frozen_string_literal: true

module Apiwork
  module Introspection
    module Dump
      class Resource
        def initialize(resource, api_class, parent_identifiers: [])
          @resource = resource
          @api_class = api_class
          @parent_identifiers = parent_identifiers
        end

        def to_h
          resource_segment = @resource.singular ? @resource.name.to_s.singularize : @resource.name.to_s

          formatted_segment = @resource.path ||
                              @api_class.transform_path_segment(resource_segment)

          resource_path = build_resource_path(formatted_segment)
          contract_class = resolve_contract_class

          {
            actions: build_actions(contract_class, resource_path),
            identifier: @resource.name.to_s,
            parent_identifiers: @parent_identifiers,
            path: resource_path,
            resources: build_nested_resources(resource_path),
          }
        end

        private

        def build_actions(contract_class, resource_path)
          actions = {}

          @resource.actions.each do |action_name, action|
            path = build_full_action_path(resource_path, action_name, action)
            actions[action_name] = { path:, method: action.method }

            action_definition = contract_class&.action_definition(action_name)
            next unless action_definition

            actions[action_name].merge!(ActionDefinition.new(action_definition).to_h.except(:deprecated))
            actions[action_name][:deprecated] = true if action_definition.deprecated
          end

          actions
        end

        def build_resource_path(formatted_segment)
          return formatted_segment if @parent_identifiers.empty?

          parent_param = ":#{@parent_identifiers.last.singularize}_id"
          "#{parent_param}/#{formatted_segment}"
        end

        def build_nested_resources(resource_path)
          return {} unless @resource.resources.any?

          child_parent_identifiers = @parent_identifiers + [@resource.name.to_s]

          @resource.resources.transform_values do |nested_resource|
            Resource.new(
              nested_resource,
              @api_class,
              parent_identifiers: child_parent_identifiers,
            ).to_h
          end
        end

        def build_full_action_path(resource_path, action_name, action)
          segment = action_path_segment(action_name, action)
          full_path = "/#{resource_path}#{segment}"
          full_path.delete_suffix('/')
        end

        def action_path_segment(action_name, action)
          if action.crud?
            case action_name
            when :index, :create
              ''
            when :show, :update, :destroy
              '/:id'
            else
              ''
            end
          elsif action.member?
            "/:id/#{@api_class.transform_path_segment(action_name)}"
          elsif action.collection?
            "/#{@api_class.transform_path_segment(action_name)}"
          else
            ''
          end
        end

        def resolve_contract_class
          contract_class = @resource.resolve_contract_class
          return nil unless contract_class

          contract_class if contract_class < Apiwork::Contract::Base
        end
      end
    end
  end
end
