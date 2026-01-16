# frozen_string_literal: true

module Apiwork
  module Adapter
    # @api public
    # API capabilities for conditional type registration.
    #
    # Passed to `register_api` in your adapter. Query to determine
    # what types to register based on API structure and schema definitions.
    #
    # @example Conditional type registration
    #   def register_api(registrar, capabilities)
    #     if capabilities.sortable?
    #       registrar.type :sort_param do
    #         string :field
    #         string :direction
    #       end
    #     end
    #   end
    #
    # @example Query adapter option values
    #   def register_api(registrar, capabilities)
    #     strategies = capabilities.options_for(:pagination, :strategy)
    #     if strategies.include?(:offset)
    #       registrar.type :offset_pagination do
    #         integer :page
    #       end
    #     end
    #   end
    class Capabilities
      # @api public
      # @return [Array<Symbol>] data types used in filterable attributes
      attr_reader :filter_types

      # @api public
      # @return [Array<Symbol>] data types used in nullable filterable attributes
      attr_reader :nullable_filter_types

      def initialize(structure)
        @structure = structure
        schema_classes = structure.schema_classes
        @filter_types, @nullable_filter_types = extract_filterable_type_variants(schema_classes)
        @sortable = check_sortable(schema_classes)
        @resources = structure.has_resources?
        @index_actions = structure.has_index_actions?
      end

      # @api public
      # @return [Boolean] true if any schema has sortable attributes or associations
      def sortable?
        @sortable
      end

      # @api public
      # @return [Boolean] true if any schema has filterable attributes
      def filterable?
        filter_types.any?
      end

      # @api public
      # @return [Boolean] true if the API has any resources registered
      def resources?
        @resources
      end

      # @api public
      # @return [Boolean] true if any resource has an index action
      def index_actions?
        @index_actions
      end

      # @api public
      # Returns all unique values for an adapter option across schemas.
      # @param option [Symbol] the option name
      # @param key [Symbol, nil] optional nested key
      # @return [Set<Object>] unique option values
      def options_for(option, key = nil)
        @structure.schema_classes
          .filter_map { |schema| schema.adapter_config.dig(option, key) }
          .to_set
      end

      private

      def extract_filterable_type_variants(schemas)
        filterable_attributes = schemas
          .flat_map { |schema| schema.attributes.values }
          .select(&:filterable?)

        filterable = filterable_attributes.map(&:type).to_set
        nullable = filterable_attributes.select(&:nullable?).map(&:type).to_set

        [filterable.to_a, nullable.to_a]
      end

      def check_sortable(schemas)
        schemas.any? do |schema|
          schema.attributes.values.any?(&:sortable?) ||
            schema.associations.values.any?(&:sortable?)
        end
      end
    end
  end
end
