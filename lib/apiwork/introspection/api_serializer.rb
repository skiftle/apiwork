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

        result[:error_codes] = @api_class.metadata.error_codes || []

        result
      end

      private

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
        metadata_info = @api_class.metadata.info
        result = {}

        if metadata_info
          result[:title] = metadata_info[:title]
          result[:version] = metadata_info[:version]
          result[:description] = metadata_info[:description]
        end

        result
      end
    end
  end
end
