# frozen_string_literal: true

module Apiwork
  module Export
    class SorbusMapper
      class << self
        def map(export, surface)
          new(export).map(surface)
        end
      end

      def initialize(export)
        @export = export
        @zod_mapper = ZodMapper.new(export)
        @type_script_mapper = TypeScriptMapper.new(export)
      end

      def map(surface)
        @surface = surface

        [
          "import { z } from 'zod';",
          @zod_mapper.build_enum_schemas(surface.enums).presence,
          @zod_mapper.build_type_schemas(surface.types).presence,
          build_typescript_types.presence,
          build_contract,
        ].compact.join("\n\n")
      end

      private

      def build_typescript_types
        types = @type_script_mapper.build_enum_types(@surface.enums) +
                @type_script_mapper.build_type_definitions(@surface.types)

        types.sort_by { |entry| entry[:name] }.map { |entry| entry[:code] }.join("\n\n")
      end

      def build_contract
        contract = {
          endpoints: build_endpoint_tree(@export.api.resources),
          error: build_error_schema,
        }
        "export const contract = #{format_object(contract, indent: 0)} as const;"
      end

      def build_endpoint_tree(resources, parent_identifiers: [])
        resources.each_with_object({}) do |(name, resource), tree|
          resource_key = @export.transform_key(name)
          identifiers = parent_identifiers + [resource.identifier]

          endpoints = resource.actions.each_with_object({}) do |(action_name, action), actions|
            actions[@export.transform_key(action_name)] = build_endpoint(
              resource.identifier.to_sym, action_name, action
            )
          end

          endpoints.merge!(build_endpoint_tree(resource.resources, parent_identifiers: identifiers))
          tree[resource_key] = endpoints
        end
      end

      def build_endpoint(resource_name, action_name, action)
        path = transform_path(action.path)
        endpoint = { path:, method: action.method.to_s.upcase }

        path_params = extract_path_params(action.path)
        endpoint[:pathParams] = build_path_params_schema(path_params) if path_params.any?

        request = build_request(action.request)
        endpoint[:request] = request if request

        response = build_response(action.response)
        endpoint[:response] = response if response

        errors = resolve_errors(action)
        endpoint[:errors] = errors if errors.any?

        endpoint
      end

      def transform_path(path)
        path.gsub(%r{(/:?)(\w+)}) do
          "#{::Regexp.last_match(1)}#{@export.transform_key(::Regexp.last_match(2))}"
        end
      end

      def extract_path_params(path)
        path.scan(/:(\w+)/).flatten
      end

      def build_path_params_schema(params)
        properties = params.map { |param| "#{@export.transform_key(param)}: z.string()" }.join(', ')
        "z.object({ #{properties} })"
      end

      def build_request(request)
        return unless request.query? || request.body?

        hash = {}
        hash[:query] = build_params_schema(request.query) if request.query?
        hash[:body] = build_params_schema(request.body) if request.body?
        hash
      end

      def build_response(response)
        return unless response.body?

        { body: @zod_mapper.map_param(response.body) }
      end

      def build_params_schema(params)
        properties = params.sort_by { |name, _| name.to_s }.map do |name, param|
          "#{@export.transform_key(name)}: #{@zod_mapper.map_field(param)}"
        end.join(', ')
        "z.object({ #{properties} })"
      end

      def build_error_schema
        'ErrorSchema'
      end

      def resolve_errors(action)
        action.raises.map { |code| @export.api.error_codes[code].status }.sort.uniq
      end

      def format_object(hash, indent:)
        return '{}' if hash.empty?

        padding = '  ' * (indent + 1)
        closing_padding = '  ' * indent

        entries = hash.map do |key, value|
          formatted_value = format_value(value, indent: indent + 1)
          "#{padding}#{key}: #{formatted_value},"
        end

        "{\n#{entries.join("\n")}\n#{closing_padding}}"
      end

      def format_value(value, indent:)
        case value
        when Hash
          format_object(value, indent:)
        when String
          if value.start_with?('z.') || value.end_with?('Schema')
            value
          else
            "'#{value}'"
          end
        when Array
          "[#{value.join(', ')}]"
        else
          value.to_s
        end
      end
    end
  end
end
