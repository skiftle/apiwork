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

          {
            resources:,
            enums: @type_dump.enums,
            error_codes: build_error_codes(collect_all_error_codes(resources)),
            info: build_info,
            path: @api_class.path,
            raises: @api_class.structure.raises,
            types: @type_dump.types,
          }
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

        def build_error_codes(codes)
          locale_key = @api_class.structure.locale_key

          codes.each_with_object({}) do |code, hash|
            error_code = Apiwork::ErrorCode.fetch(code)
            hash[code] = {
              description: error_code.description(locale_key:),
              status: error_code.status,
            }
          end
        end

        def build_resources
          @api_class.structure.resources.transform_values do |resource|
            Resource.new(resource, @api_class).to_h
          end
        end

        def build_info
          info = @api_class.structure.info
          return {} unless info

          {
            contact: info[:contact],
            description: info[:description],
            license: info[:license],
            servers: info[:servers] || [],
            summary: info[:summary],
            terms_of_service: info[:terms_of_service],
            title: info[:title],
            version: info[:version],
          }
        end
      end
    end
  end
end
