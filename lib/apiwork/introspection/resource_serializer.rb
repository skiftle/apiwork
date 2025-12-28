# frozen_string_literal: true

module Apiwork
  module Introspection
    class ResourceSerializer
      def initialize(api_class, resource_name, resource, parent_path: nil, parent_resource_name: nil)
        @api_class = api_class
        @resource_name = resource_name
        @resource = resource
        @parent_path = parent_path
        @parent_resource_name = parent_resource_name
      end

      def serialize
        resource_segment = @resource.singular ? @resource_name.to_s.singularize : @resource_name.to_s

        formatted_segment = @resource.options[:path] ||
                            @api_class.transform_path_segment(resource_segment)

        resource_path = if @parent_path
                          ":#{@parent_resource_name.to_s.singularize}_id/#{formatted_segment}"
                        else
                          formatted_segment
                        end

        contract_class = resolve_contract_class

        {
          identifier: @resource_name.to_s,
          path: resource_path,
          actions: build_actions(contract_class),
          resources: build_nested_resources(resource_path)
        }.compact
      end

      private

      def build_actions(contract_class)
        actions = {}

        @resource.actions.each do |action_name, action|
          path = action_path(action_name, action)
          actions[action_name] = { method: action.method, path: }

          action_definition = contract_class&.action_definition(action_name)
          next unless action_definition

          actions[action_name].merge!(ActionSerializer.new(action_definition).serialize.except(:deprecated).compact)
          actions[action_name][:deprecated] = true if action_definition.deprecated
        end

        actions
      end

      def build_nested_resources(resource_path)
        return nil unless @resource.resources.any?

        @resource.resources.each_with_object({}) do |(nested_name, nested_resource), result|
          result[nested_name] = ResourceSerializer.new(
            @api_class,
            nested_name,
            nested_resource,
            parent_path: resource_path,
            parent_resource_name: @resource_name
          ).serialize
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

        contract_class if contract_class < Contract::Base
      end
    end
  end
end
