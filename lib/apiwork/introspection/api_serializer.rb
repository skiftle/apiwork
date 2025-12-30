# frozen_string_literal: true

module Apiwork
  module Introspection
    class APISerializer
      def initialize(api_class)
        @api_class = api_class
        @type_serializer = TypeSerializer.new(api_class)
      end

      def serialize
        resources = serialize_resources

        {
          resources:,
          enums: @type_serializer.serialize_enums.presence,
          error_codes: serialize_error_codes(collect_all_error_codes(resources)).presence,
          info: serialize_info.presence,
          path: @api_class.path,
          raises: @api_class.structure.raises.presence,
          types: @type_serializer.serialize_types.presence,
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
            description: error_code.description(locale_key:),
            status: error_code.status,
          }
        end
      end

      def serialize_resources
        @api_class.structure.resources.transform_values do |resource|
          ResourceSerializer.new(resource, @api_class).serialize
        end
      end

      def serialize_info
        info = @api_class.structure.info
        return nil unless info

        {
          contact: info[:contact],
          description: info[:description],
          license: info[:license],
          servers: info[:servers],
          summary: info[:summary],
          terms_of_service: info[:terms_of_service],
          title: info[:title],
          version: info[:version],
        }.compact.presence
      end
    end
  end
end
