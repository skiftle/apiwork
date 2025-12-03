# frozen_string_literal: true

module Apiwork
  module Introspection
    class ApiSerializer
      def initialize(api_class)
        @api_class = api_class
      end

      def serialize
        return nil unless @api_class.metadata

        resources = serialize_resources

        result = {
          path: @api_class.mount_path,
          info: serialize_info,
          types: TypeSerializer.new(@api_class).serialize_types,
          enums: TypeSerializer.new(@api_class).serialize_enums,
          resources: resources
        }

        result[:error_codes] = serialize_error_codes(@api_class.metadata.error_codes || [])

        result
      end

      private

      def serialize_error_codes(codes)
        api_path = @api_class.metadata.path.delete_prefix('/')

        codes.each_with_object({}) do |code, hash|
          hash[code] = resolve_error_description(code, api_path)
        end
      end

      def resolve_error_description(code, api_path)
        api_key = :"apiwork.apis.#{api_path}.error_codes.#{code}"
        result = I18n.t(api_key, default: nil)
        return result if result

        global_key = :"apiwork.error_codes.#{code}"
        result = I18n.t(global_key, default: nil)
        return result if result

        code.to_s.titleize
      end

      def serialize_resources
        resources = {}
        @api_class.metadata.resources.each do |resource_name, resource_metadata|
          resources[resource_name] = ResourceSerializer.new(
            @api_class,
            resource_name,
            resource_metadata
          ).serialize
        end
        resources
      end

      def serialize_info
        info = @api_class.metadata.info
        result = {}

        if info
          result[:title] = info[:title]
          result[:version] = info[:version]
          result[:description] = info[:description]
        end

        result
      end
    end
  end
end
