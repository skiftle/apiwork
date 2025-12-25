# frozen_string_literal: true

module Apiwork
  module Adapter
    # @api public
    # Aggregated schema information for type registration.
    #
    # Passed to `register_api` in your adapter. Use to conditionally
    # register types based on what schemas define (filtering, sorting, pagination).
    #
    # @example Conditional type registration
    #   def register_api(registrar, schema_summary)
    #     if schema_summary.uses_offset_pagination?
    #       registrar.type :offset_pagination do
    #         param :page, type: :integer
    #         param :per_page, type: :integer
    #       end
    #     end
    #
    #     if schema_summary.sortable?
    #       registrar.type :sort_param do
    #         param :field, type: :string
    #         param :direction, type: :string
    #       end
    #     end
    #   end
    class SchemaSummary
      # @api public
      # @return [Array<Symbol>] data types used in filterable attributes
      attr_reader :filterable_types

      # @api public
      # @return [Array<Symbol>] data types used in nullable filterable attributes
      attr_reader :nullable_filterable_types

      def initialize(schemas, has_resources: false, has_index_actions: false)
        @filterable_types, @nullable_filterable_types = extract_filterable_type_variants(schemas)
        @sortable = check_sortable(schemas)
        @has_resources = has_resources
        @has_index_actions = has_index_actions
        @pagination_strategies = extract_pagination_strategies(schemas)
      end

      # @api public
      # @return [Boolean] true if any schema has sortable attributes or associations
      def sortable?
        @sortable
      end

      # @api public
      # @return [Boolean] true if any schema has filterable attributes
      def filterable?
        filterable_types.any?
      end

      # @api public
      # @return [Boolean] true if any pagination strategy is used
      def paginatable?
        uses_offset_pagination? || uses_cursor_pagination?
      end

      # @api public
      # @return [Boolean] true if the API has any resources registered
      def has_resources?
        @has_resources
      end

      # @api public
      # @return [Boolean] true if any resource has an index action
      def has_index_actions?
        @has_index_actions
      end

      # @api public
      # @return [Boolean] true if any schema uses offset pagination
      def uses_offset_pagination?
        @pagination_strategies.include?(:offset)
      end

      # @api public
      # @return [Boolean] true if any schema uses cursor pagination
      def uses_cursor_pagination?
        @pagination_strategies.include?(:cursor)
      end

      private

      def extract_filterable_type_variants(schemas)
        filterable = Set.new
        nullable = Set.new

        schemas.each do |schema|
          schema.attribute_definitions.each_value do |attribute_definition|
            next unless attribute_definition.filterable?

            type = attribute_definition.type
            filterable.add(type)
            nullable.add(type) if attribute_definition.nullable?
          end
        end

        [filterable.to_a, nullable.to_a]
      end

      def check_sortable(schemas)
        schemas.any? do |schema|
          schema.attribute_definitions.values.any?(&:sortable?) ||
            schema.association_definitions.values.any?(&:sortable?)
        end
      end

      def extract_pagination_strategies(schemas)
        strategies = Set.new
        schemas.each do |schema|
          strategy = schema.resolve_option(:pagination, :strategy)
          strategies.add(strategy) if strategy
        end
        strategies
      end
    end
  end
end
