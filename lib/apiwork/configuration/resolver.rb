# frozen_string_literal: true

module Apiwork
  module Configuration
    # Resolves configuration values through three-level inheritance chain:
    # API → Schema → Contract (Contract wins, deep merge)
    module Resolver
      # Configuration settings with their default values
      DEFAULTS = {
        output_key_format: :keep,
        input_key_format: :keep,
        default_sort: { id: :asc },
        default_page_size: 20,
        max_page_size: 200,
        max_array_items: 1000
      }.freeze

      # Settings that require deep merge (Hash values)
      MERGEABLE_SETTINGS = [:default_sort].freeze

      module_function

      # Resolves a configuration setting through the inheritance chain
      #
      # @param setting_name [Symbol] The configuration setting to resolve
      # @param contract_class [Class, nil] Contract class (highest priority)
      # @param schema_class [Class, nil] Schema class (medium priority)
      # @param api_class [Apiwork::API::Base, nil] API instance (lowest priority)
      # @return [Object] The resolved configuration value
      def resolve(setting_name, contract_class: nil, schema_class: nil, api_class: nil)
        # Auto-resolve related classes if not explicitly provided
        schema_class = contract_class.schema_class if contract_class && !schema_class

        if contract_class && !api_class
          api_class = contract_class.api_class
        elsif schema_class && !api_class
          api_class = schema_class.api_class
        end

        # Collect values from all levels (skip nil classes)
        values = []

        values << contract_class.configuration[setting_name] if contract_class&.configuration&.key?(setting_name)
        values << schema_class.configuration[setting_name] if schema_class&.configuration&.key?(setting_name)
        values << api_class.configuration[setting_name] if api_class&.configuration&.key?(setting_name)

        # If no values set anywhere, use default
        return DEFAULTS[setting_name] if values.empty?

        # For mergeable settings (Hashes), deep merge from API → Schema → Contract
        if MERGEABLE_SETTINGS.include?(setting_name)
          deep_merge_values(values.reverse) # Reverse to merge API → Schema → Contract
        else
          # For non-mergeable settings, highest priority wins (first value = Contract)
          values.first
        end
      end

      # Deep merges hash values from lowest to highest priority
      # @param values [Array<Hash>] Array of hash values to merge
      # @return [Hash] Deep merged hash
      def deep_merge_values(values)
        values.reduce({}) do |merged, value|
          deep_merge(merged, value)
        end
      end

      # Deep merges two hashes
      # @param hash1 [Hash] Base hash
      # @param hash2 [Hash] Hash to merge into base (higher priority)
      # @return [Hash] Merged hash
      def deep_merge(hash1, hash2)
        hash1.merge(hash2) do |_key, old_value, new_value|
          if old_value.is_a?(Hash) && new_value.is_a?(Hash)
            deep_merge(old_value, new_value)
          else
            new_value
          end
        end
      end
    end
  end
end
