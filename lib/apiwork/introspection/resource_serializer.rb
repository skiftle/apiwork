# frozen_string_literal: true

module Apiwork
  module Introspection
    class ResourceSerializer
      def initialize(api_class, resource_name, resource_metadata, parent_path: nil, parent_resource_name: nil)
        @api_class = api_class
        @resource_name = resource_name
        @resource_metadata = resource_metadata
        @parent_path = parent_path
        @parent_resource_name = parent_resource_name
      end

      def serialize
        resource_segment = @resource_metadata[:singular] ? @resource_name.to_s.singularize : @resource_name.to_s
        resource_path = if @parent_path
                          ":#{@parent_resource_name.to_s.singularize}_id/#{resource_segment}"
                        else
                          resource_segment
                        end

        metadata = @resource_metadata[:metadata] || {}
        contract_class = resolve_contract_class

        {
          path: resource_path,
          summary: metadata[:summary],
          description: metadata[:description],
          tags: metadata[:tags].presence,
          actions: build_actions(contract_class),
          resources: build_nested_resources(resource_path)
        }.compact
      end

      private

      def build_actions(contract_class)
        actions = {}
        add_actions(actions, @resource_metadata[:actions], :standard, contract_class)
        add_actions(actions, @resource_metadata[:members], :member, contract_class)
        add_actions(actions, @resource_metadata[:collections], :collection, contract_class)
        actions
      end

      def add_actions(actions, action_source, action_type, contract_class)
        return unless action_source&.any?

        action_source.each do |action_name, action_data|
          path_type = action_type == :standard ? action_name.to_sym : action_type
          path = action_path(action_name, path_type)

          actions[action_name] = { method: action_data[:method], path: }

          action_definition = contract_class&.action_definition(action_name)
          next unless action_definition

          actions[action_name].merge!(ActionSerializer.new(action_definition).serialize.except(:deprecated).compact)
          actions[action_name][:deprecated] = true if action_definition.deprecated
        end
      end

      def build_nested_resources(resource_path)
        return nil unless @resource_metadata[:resources]&.any?

        @resource_metadata[:resources].each_with_object({}) do |(nested_name, nested_metadata), result|
          result[nested_name] = ResourceSerializer.new(
            @api_class,
            nested_name,
            nested_metadata,
            parent_path: resource_path,
            parent_resource_name: @resource_name
          ).serialize
        end
      end

      def action_path(action_name, action_type)
        case action_type
        when :index, :create
          '/'
        when :show, :update, :destroy
          '/:id'
        when :member
          "/:id/#{action_name}"
        when :collection
          "/#{action_name}"
        else
          '/'
        end
      end

      def resolve_contract_class
        contract_class = @resource_metadata[:contract_class]

        unless contract_class
          contract_name = @resource_metadata[:contract]
          return nil unless contract_name

          contract_class = @resource_metadata[:contract_class] = begin
            contract_name.constantize
          rescue StandardError
            nil
          end
        end

        return nil unless contract_class

        contract_class < Contract::Base ? contract_class : nil
      end

    end
  end
end
