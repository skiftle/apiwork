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
          type_dump_hash = @type_dump.to_h

          {
            resources:,
            base_path: @api_class.transform_path(@api_class.base_path),
            enums: type_dump_hash[:enums],
            error_codes: build_error_codes(collect_all_error_code_keys(resources)),
            info: build_info,
            types: type_dump_hash[:types],
          }
        end

        private

        def collect_all_error_code_keys(resources)
          error_code_keys = Set.new(@api_class.raises)

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
          error_code_keys.each_with_object({}) do |code, hash|
            error_code = Apiwork::ErrorCode.find!(code)
            hash[code] = {
              description: error_code.description(locale_key: @api_class.locale_key),
              status: error_code.status,
            }
          end
        end

        def build_resources
          @api_class.root_resource.resources.transform_values do |resource|
            Resource.new(resource, @api_class).to_h
          end
        end

        def build_info
          info = @api_class.info
          return nil unless info

          {
            contact: build_contact(info.contact),
            deprecated: info.deprecated?,
            description: info.description,
            license: build_license(info.license),
            servers: build_servers(info.server),
            summary: info.summary,
            tags: info.tags,
            terms_of_service: info.terms_of_service,
            title: info.title,
            version: info.version,
          }
        end

        def build_contact(contact)
          return nil unless contact

          {
            email: contact.email,
            name: contact.name,
            url: contact.url,
          }
        end

        def build_license(license)
          return nil unless license

          {
            name: license.name,
            url: license.url,
          }
        end

        def build_servers(servers)
          servers.map do |server|
            {
              description: server.description,
              url: server.url,
            }
          end
        end
      end
    end
  end
end
