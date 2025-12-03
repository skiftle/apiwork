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
        all_error_codes = collect_all_error_codes(resources)

        {
          path: @api_class.mount_path,
          info: serialize_info,
          types: TypeSerializer.new(@api_class).serialize_types,
          enums: TypeSerializer.new(@api_class).serialize_enums,
          errors: serialize_errors(all_error_codes),
          error_codes: @api_class.metadata.error_codes || [],
          resources: resources
        }
      end

      private

      def collect_all_error_codes(resources)
        codes = Set.new(@api_class.metadata.error_codes || [])

        collect_action_error_codes(resources, codes)

        codes.to_a.sort_by(&:to_s)
      end

      def collect_action_error_codes(resources, codes)
        resources.each_value do |resource_data|
          resource_data[:actions]&.each_value do |action_data|
            codes.merge(action_data[:error_codes] || [])
          end

          collect_action_error_codes(resource_data[:resources], codes) if resource_data[:resources]
        end
      end

      def serialize_errors(codes)
        api_path = @api_class.metadata.path.delete_prefix('/')

        codes.each_with_object({}) do |code, hash|
          error_code = ErrorCode.fetch(code)
          hash[code] = {
            status: error_code.status,
            description: resolve_error_description(code, api_path)
          }
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
