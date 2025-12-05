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

        result = {
          path: resource_path,
          summary: metadata[:summary],
          description: metadata[:description],
          tags: metadata[:tags],
          actions: {}
        }

        contract_class = resolve_contract_class
        schema_class = resolve_schema_class

        result[:schema] = serialize_resource_schema(schema_class) if schema_class

        add_actions(result[:actions], @resource_metadata[:actions], :standard, contract_class)
        add_actions(result[:actions], @resource_metadata[:members], :member, contract_class)
        add_actions(result[:actions], @resource_metadata[:collections], :collection, contract_class)
        add_nested_resources(result, resource_path) if @resource_metadata[:resources]&.any?

        result
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

      def add_actions(actions, action_source, action_type, contract_class)
        return unless action_source&.any?

        action_source.each do |action_name, action_data|
          path_type = action_type == :standard ? action_name.to_sym : action_type
          path = action_path(action_name, path_type)
          add_action(actions, action_name, action_data[:method], path, contract_class,
                     metadata: action_data[:metadata])
        end
      end

      def add_nested_resources(result, resource_path)
        result[:resources] = {}
        @resource_metadata[:resources].each do |nested_name, nested_metadata|
          result[:resources][nested_name] = ResourceSerializer.new(
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

      def add_action(actions, name, method, path, contract_class, metadata: {})
        actions[name] = {
          method: method,
          path: path
        }

        return unless contract_class

        action_definition = contract_class.action_definition(name)
        return unless action_definition

        contract_json = ActionSerializer.new(action_definition).serialize

        actions[name][:summary] = contract_json[:summary]
        actions[name][:description] = contract_json[:description]
        actions[name][:tags] = contract_json[:tags]
        actions[name][:deprecated] = contract_json[:deprecated]
        actions[name][:operation_id] = contract_json[:operation_id]
        actions[name][:request] = contract_json[:request] if contract_json[:request]
        actions[name][:response] = contract_json[:response] if contract_json[:response]
        actions[name][:raises] = contract_json[:raises] || []
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

        attributes = {}
        schema_class.attribute_definitions.each do |attr_name, attr_def|
          attr_hash = {
            type: attr_def.type,
            nullable: attr_def.nullable?,
            format: attr_def.format,
            example: attr_def.example,
            description: attr_def.description,
            deprecated: attr_def.deprecated
          }
          attr_hash[:optional] = true if attr_def.optional?
          attributes[attr_name] = attr_hash.compact
        end

        {
          type: :object,
          shape: attributes
        }
      end
    end
  end
end
