# frozen_string_literal: true

module Apiwork
  module Introspection
    module Dump
      class Resource
        def initialize(resource, api_class, parent_path: nil, parent_resource: nil)
          @resource = resource
          @api_class = api_class
          @parent_path = parent_path
          @parent_resource = parent_resource
        end

        def to_h
          resource_segment = @resource.singular ? @resource.name.to_s.singularize : @resource.name.to_s

          formatted_segment = @resource.path ||
                              @api_class.transform_path_segment(resource_segment)

          resource_path = if @parent_path
                            ":#{@parent_resource.name.to_s.singularize}_id/#{formatted_segment}"
                          else
                            formatted_segment
                          end

          contract_class = resolve_contract_class

          {
            actions: build_actions(contract_class),
            identifier: @resource.name.to_s,
            path: resource_path,
            resources: build_nested_resources(resource_path),
          }.compact
        end

        private

        def build_actions(contract_class)
          actions = {}

          @resource.actions.each do |action_name, action|
            path = action_path(action_name, action)
            actions[action_name] = { path:, method: action.method }

            action_definition = contract_class&.action_definition(action_name)
            next unless action_definition

            actions[action_name].merge!(ActionDefinition.new(action_definition).to_h.except(:deprecated).compact)
            actions[action_name][:deprecated] = true if action_definition.deprecated
          end

          actions
        end

        def build_nested_resources(resource_path)
          return nil unless @resource.resources.any?

          @resource.resources.transform_values do |nested_resource|
            Resource.new(
              nested_resource,
              @api_class,
              parent_path: resource_path,
              parent_resource: @resource,
            ).to_h
          end
        end

        def action_path(action_name, action)
          if action.crud?
            case action_name
            when :index, :create
              '/'
            when :show, :update, :destroy
              '/:id'
            else
              '/'
            end
          elsif action.member?
            "/:id/#{@api_class.transform_path_segment(action_name)}"
          elsif action.collection?
            "/#{@api_class.transform_path_segment(action_name)}"
          else
            '/'
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
