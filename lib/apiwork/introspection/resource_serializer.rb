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
        resource_path = build_resource_path
        metadata = @resource_metadata[:metadata] || {}
        contract_class = resolve_contract_class

        {
          path: resource_path,
          summary: metadata[:summary],
          description: metadata[:description],
          tags: metadata[:tags].presence,
          schema: serialize_resource_schema(resolve_schema_class),
          actions: build_actions(contract_class),
          resources: build_nested_resources(resource_path)
        }.compact
      end

      private

      def build_resource_path
        resource_segment = if @resource_metadata[:singular]
                             @resource_name.to_s.singularize
                           else
                             @resource_name.to_s
                           end

        if @parent_path
          parent_id_param = ":#{@parent_resource_name.to_s.singularize}_id"
          "#{parent_id_param}/#{resource_segment}"
        else
          resource_segment
        end
      end

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
          add_action(actions, action_name, action_data[:method], action_path(action_name, path_type), contract_class)
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

      def add_action(actions, name, method, path, contract_class)
        actions[name] = { method:, path: }

        action_definition = contract_class&.action_definition(name)
        return unless action_definition

        actions[name].merge!(ActionSerializer.new(action_definition).serialize.except(:deprecated).compact)
        actions[name][:deprecated] = true if action_definition.deprecated
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

      def resolve_schema_class
        contract_class = resolve_contract_class
        contract_class&.schema_class
      end

      def serialize_resource_schema(schema_class)
        return nil unless schema_class.respond_to?(:attribute_definitions)

        attributes = schema_class.attribute_definitions.transform_values { serialize_attribute(_1) }
        return nil if attributes.empty?

        { type: :object, shape: attributes }
      end

      def serialize_attribute(attr_def)
        result = {
          type: attr_def.type,
          format: attr_def.format,
          example: attr_def.example,
          description: attr_def.description
        }.compact

        result[:nullable] = true if attr_def.nullable?
        result[:optional] = true if attr_def.optional?
        result[:deprecated] = true if attr_def.deprecated

        result
      end
    end
  end
end
