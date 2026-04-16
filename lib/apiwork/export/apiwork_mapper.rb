# frozen_string_literal: true

module Apiwork
  module Export
    class ApiworkMapper
      class << self
        def map(export, surface)
          new(export).map(surface)
        end
      end

      def initialize(export)
        @export = export
      end

      def map(surface)
        {
          base_path: @export.api.base_path,
          enums: serialize_enums(surface.enums),
          error_codes: serialize_error_codes,
          fingerprint: @export.api.fingerprint,
          info: serialize_info,
          locales: @export.api.locales.map(&:to_s),
          resources: serialize_resources(@export.api.resources),
          types: serialize_types(surface.types),
        }
      end

      private

      def serialize_enums(enums)
        enums.map do |name, enum|
          {
            deprecated: enum.deprecated?,
            description: enum.description,
            example: enum.example,
            name: name.to_s,
            scope: enum.scope,
            values: enum.values,
          }
        end
      end

      def serialize_error_codes
        @export.api.error_codes.map do |name, error_code|
          {
            description: error_code.description,
            name: name.to_s,
            status: error_code.status,
          }
        end
      end

      def serialize_info
        info = @export.api.info
        return unless info

        {
          contact: info.contact && {
            email: info.contact.email,
            name: info.contact.name,
            url: info.contact.url,
          },
          description: info.description,
          license: info.license && {
            name: info.license.name,
            url: info.license.url,
          },
          servers: info.servers.map do |server|
            { description: server.description, url: server.url }
          end,
          summary: info.summary,
          terms_of_service: info.terms_of_service,
          title: info.title,
          version: info.version,
        }
      end

      def serialize_types(types)
        type_hashes = types.transform_values(&:to_h)
        sorted = TypeAnalysis.topological_sort_types(type_hashes)
        recursive = TypeAnalysis.cycle_breaking_types(type_hashes)

        sorted.map { |name, _| serialize_type(name, types[name], recursive: recursive.include?(name)) }
      end

      def serialize_type(name, type, recursive:)
        result = {
          recursive:,
          deprecated: type.deprecated?,
          description: type.description,
          example: type.example,
          name: name.to_s,
          scope: type.scope,
          type: type.type.to_s,
        }

        if type.object?
          result[:extends] = type.extends.map(&:to_s)
          result[:shape] = serialize_shape(type.shape)
        else
          result[:discriminator] = transform_key(type.discriminator)
          result[:variants] = type.variants.map do |variant|
            serialized = serialize_param(variant)
            serialized[:tag] = variant.tag if variant.respond_to?(:tag) && variant.tag
            serialized
          end
        end

        result
      end

      def serialize_resources(resources, prefix: nil)
        resources.map do |name, resource|
          qualified_name = prefix ? "#{prefix}.#{name}" : name.to_s

          {
            actions: resource.actions.map do |action_name, action|
              serialize_action(action, name: "#{qualified_name}.#{action_name}")
            end,
            identifier: resource.identifier.to_s,
            name: name.to_s,
            parent_identifiers: resource.parent_identifiers.map(&:to_s),
            path: transform_path(resource.path),
            resources: serialize_resources(resource.resources, prefix: qualified_name),
            scope: resource.scope,
          }
        end
      end

      def serialize_action(action, name:)
        {
          name:,
          deprecated: action.deprecated?,
          description: action.description,
          method: action.method.to_s,
          operation_id: action.operation_id,
          path: transform_path(action.path),
          raises: action.raises.map(&:to_s),
          request: {
            body: serialize_shape(action.request.body),
            description: action.request.description,
            query: serialize_shape(action.request.query),
          },
          response: {
            body: serialize_response_body(action.response),
            description: action.response.description,
            no_content: action.response.no_content?,
          },
          summary: action.summary,
          tags: action.tags,
        }
      end

      def serialize_response_body(response)
        return unless response.body?

        serialize_param(response.body)
      end

      def serialize_shape(params)
        params.sort_by { |name, _| name.to_s }.map do |name, param|
          { name: transform_key(name) }.merge(serialize_param(param))
        end
      end

      def serialize_param(param)
        result = {
          deprecated: param.deprecated?,
          description: param.description,
          nullable: param.nullable?,
          optional: param.optional?,
          type: param.type.to_s,
        }

        case param.type
        when :string, :integer
          result[:default] = param.default if param.default?
          result[:enum] = param.enum.to_s if param.enum?
          result[:example] = param.example
          result[:format] = param.format
          result[:max] = param.max
          result[:min] = param.min
        when :number, :decimal
          result[:default] = param.default if param.default?
          result[:enum] = param.enum.to_s if param.enum?
          result[:example] = param.example
          result[:max] = param.max
          result[:min] = param.min
        when :boolean, :date, :datetime, :time, :uuid, :binary
          result[:default] = param.default if param.default?
          result[:enum] = param.enum.to_s if param.enum?
          result[:example] = param.example
        when :literal
          result[:value] = param.value
        when :array
          result[:default] = param.default if param.default?
          result[:example] = param.example
          result[:max] = param.max
          result[:min] = param.min
          result[:of] = param.of ? serialize_param(param.of) : nil
        when :record
          result[:default] = param.default if param.default?
          result[:example] = param.example
          result[:of] = param.of ? serialize_param(param.of) : nil
        when :object
          result[:partial] = param.partial?
          result[:shape] = serialize_shape(param.shape)
        when :union
          result[:discriminator] = transform_key(param.discriminator)
          result[:variants] = param.variants.map do |variant|
            serialized = serialize_param(variant)
            serialized[:tag] = variant.tag if variant.respond_to?(:tag) && variant.tag
            serialized
          end
        when :reference
          result[:reference] = param.reference.to_s
        end

        result
      end

      def transform_path(path)
        path.to_s.gsub(/:(\w+)/) { ":#{transform_key(::Regexp.last_match(1))}" }
      end

      def transform_key(key)
        @export.transform_key(key)
      end
    end
  end
end
