# frozen_string_literal: true

module Apiwork
  module Introspection
    module Dump
      class API
        def initialize(api_class)
          @api_class = api_class
          @type_dump = Type.new(api_class)
        end

        def to_h
          resources = build_resources
          type_data = @type_dump.to_h

          {
            resources:,
            enums: type_data[:enums],
            error_codes: build_error_codes(collect_all_error_code_keys(resources)),
            info: build_info,
            path: @api_class.path,
            types: type_data[:types],
          }
        end

        private

        def collect_all_error_code_keys(resources)
          error_code_keys = Set.new(@api_class.structure.raises)

          collect_action_error_codes(resources, error_code_keys)

          error_code_keys.to_a.sort_by(&:to_s)
        end

        def collect_action_error_codes(resources, error_code_keys)
          resources.each_value do |resource|
            resource[:actions]&.each_value do |action|
              error_code_keys.merge(action[:raises] || [])
            end

            collect_action_error_codes(resource[:resources], error_code_keys) if resource[:resources]
          end
        end

        def build_error_codes(error_code_keys)
          locale_key = @api_class.structure.locale_key

          error_code_keys.each_with_object({}) do |code, hash|
            error_code = Apiwork::ErrorCode.fetch(code)
            hash[code] = error_code.to_h(locale_key:)
          end
        end

        def build_resources
          @api_class.structure.resources.transform_values do |resource|
            Resource.new(resource, @api_class).to_h
          end
        end

        def build_info
          info = @api_class.structure.info
          return nil unless info

          data = info.to_h
          {
            contact: data[:contact],
            deprecated: data[:deprecated],
            description: data[:description],
            license: data[:license],
            servers: data[:servers] || [],
            summary: data[:summary],
            tags: data[:tags],
            terms_of_service: data[:terms_of_service],
            title: data[:title],
            version: data[:version],
          }
        end
      end
    end
  end
end
