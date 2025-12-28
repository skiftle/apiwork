# frozen_string_literal: true

module Apiwork
  module Introspection
    class APISerializer
      def initialize(api_class)
        @api_class = api_class
      end

      def serialize
        resources = serialize_resources

        {
          path: @api_class.path,
          info: serialize_info.presence,
          types: TypeSerializer.new(@api_class).serialize_types.presence,
          enums: TypeSerializer.new(@api_class).serialize_enums.presence,
          raises: @api_class.structure.raises.presence,
          error_codes: serialize_error_codes(collect_all_error_codes(resources)).presence,
          resources:
        }.compact
      end

      private

      def collect_all_error_codes(resources)
        codes = Set.new(@api_class.structure.raises)

        collect_action_error_codes(resources, codes)

        codes.to_a.sort_by(&:to_s)
      end

      def collect_action_error_codes(resources, codes)
        resources.each_value do |resource_data|
          resource_data[:actions]&.each_value do |action_data|
            codes.merge(action_data[:raises] || [])
          end

          collect_action_error_codes(resource_data[:resources], codes) if resource_data[:resources]
        end
      end

      def serialize_error_codes(codes)
        locale_key = @api_class.structure.locale_key

        codes.each_with_object({}) do |code, hash|
          error_code = ErrorCode.fetch(code)
          hash[code] = {
            status: error_code.status,
            description: error_code.description(locale_key:)
          }
        end
      end

      def serialize_resources
        resources = {}
        @api_class.structure.resources.each do |resource_name, resource_metadata|
          resources[resource_name] = ResourceSerializer.new(
            @api_class,
            resource_name,
            resource_metadata
          ).serialize
        end
        resources
      end

      def serialize_info
        info = @api_class.structure.info
        return nil unless info

        {
          title: info[:title],
          version: info[:version],
          description: info[:description],
          summary: info[:summary],
          terms_of_service: info[:terms_of_service],
          contact: info[:contact],
          license: info[:license],
          servers: info[:servers]
        }.compact.presence
      end
    end
  end
end
