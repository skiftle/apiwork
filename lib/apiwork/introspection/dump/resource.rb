# frozen_string_literal: true

module Apiwork
  module Introspection
    module Dump
      class Resource
        def initialize(resource, api_class, parent_identifiers: [], parent_param: nil)
          @resource = resource
          @api_class = api_class
          @parent_identifiers = parent_identifiers
          @parent_param = parent_param
        end

        def to_h
          formatted_segment = @api_class.transform_path(
            @resource.path || (@resource.singular ? @resource.name.to_s.singularize : @resource.name.to_s),
          )

          resource_path = build_resource_path(formatted_segment)

          {
            actions: build_actions(resolve_contract_class, resource_path),
            identifier: @resource.name.to_s,
            parent_identifiers: @parent_identifiers,
            path: resource_path,
            resources: build_nested_resources(resource_path),
          }
        end

        private

        def build_actions(contract_class, resource_path)
          actions = {}

          @resource.actions.each do |action_name, adapter_action|
            actions[action_name] = { method: adapter_action.method, path: build_full_action_path(resource_path, action_name, adapter_action) }

            contract_action = contract_class&.action_for(action_name)
            unless contract_action
              actions[action_name].merge!(
                description: nil,
                operation_id: nil,
                raises: [],
                request: { body: {}, query: {} },
                response: { body: {}, no_content: false },
                summary: nil,
                tags: [],
              )
              next
            end

            actions[action_name].merge!(Action.new(contract_action).to_h)
          end

          actions
        end

        def build_resource_path(formatted_segment)
          return formatted_segment if @parent_identifiers.empty?

          ":#{@parent_param || "#{@parent_identifiers.last.singularize}_id"}/#{formatted_segment}"
        end

        def build_nested_resources(resource_path)
          return {} unless @resource.resources.any?

          child_parent_identifiers = @parent_identifiers + [@resource.name.to_s]
          child_parent_param = @resource.param&.to_s || "#{@resource.name.to_s.singularize}_id"

          @resource.resources.transform_values do |nested_resource|
            Resource.new(
              nested_resource,
              @api_class,
              parent_identifiers: child_parent_identifiers,
              parent_param: child_parent_param,
            ).to_h
          end
        end

        def build_full_action_path(resource_path, action_name, adapter_action)
          "/#{resource_path}#{action_path_segment(action_name, adapter_action)}".delete_suffix('/')
        end

        def action_path_segment(action_name, adapter_action)
          if adapter_action.crud?
            case action_name
            when :index, :create
              ''
            when :show, :update, :destroy
              '/:id'
            else
              ''
            end
          elsif adapter_action.member?
            "/:id/#{@api_class.transform_path(action_name)}"
          elsif adapter_action.collection?
            "/#{@api_class.transform_path(action_name)}"
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
