# frozen_string_literal: true

module Apiwork
  module Configuration
    module Resolver
      DEFAULTS = {
        key_format: :keep,
        default_sort: { id: :asc },
        default_page_size: 20,
        max_page_size: 200,
        max_array_items: 1000
      }.freeze

      MERGEABLE_SETTINGS = [:default_sort].freeze
      API_ONLY_SETTINGS = [:key_format].freeze

      module_function

      def resolve(setting_name, contract_class: nil, schema_class: nil, api_class: nil)
        schema_class ||= contract_class&.schema_class
        api_class    ||= contract_class&.api_class || schema_class&.api_class

        values = collected_values(setting_name, contract_class, schema_class, api_class)

        return DEFAULTS[setting_name] if values.empty?

        MERGEABLE_SETTINGS.include?(setting_name) ? values.reverse.reduce({}, &:deep_merge) : values.first
      end

      def collected_values(name, contract_class, schema_class, api_class)
        sources = if API_ONLY_SETTINGS.include?(name)
                    [api_class]
                  else
                    [contract_class, schema_class, api_class]
                  end

        sources.compact
               .map(&:configuration)
               .select { |configuration| configuration.key?(name) }
               .map { |configuration| configuration[name] }
      end
    end
  end
end
