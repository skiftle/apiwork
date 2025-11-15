# frozen_string_literal: true

module Apiwork
  module Contract
    module Descriptor
      # Core: Register Apiwork's core global descriptors
      #
      # Core descriptors are registered at boot time and include:
      # - page, pagination (pagination)
      # - issue (issue responses)
      #
      # Conditional descriptors are registered lazily when needed:
      # - Filter descriptors (only for schemas with filterable attributes)
      # - Sort descriptor (only for schemas with sortable attributes)
      #
      module Core
        class << self
          def reset!
            @registered_filter_descriptors = Set.new
            @sort_descriptor_registered = false
          end

          def register_core_descriptors
            Apiwork.register_descriptors do
              # Pagination parameters
              # Standard pagination with page number and size
              type :page do
                param :number, type: :integer, required: false
                param :size, type: :integer, required: false
              end

              # Pagination metadata
              # Standard pagination info returned in collection responses
              type :pagination do
                param :current, type: :integer, required: true
                param :next, type: :integer, nullable: true
                param :prev, type: :integer, nullable: true
                param :total, type: :integer, required: true
                param :items, type: :integer, required: true
              end

              # Issue type
              # Standard issue structure for API responses
              type :issue do
                param :code, type: :string, required: true
                param :field, type: :string, required: true
                param :detail, type: :string, required: true
                param :path, type: :array, of: :string, required: true
              end
            end
          end

          # Ensure filter descriptors are registered for a schema's filterable attributes
          def ensure_filter_descriptors_registered(schema_class)
            needed = determine_needed_filter_descriptors(schema_class)
            needed.each { |type| register_filter_descriptor(type) }
          end

          # Ensure sort descriptor is registered if schema has sortable attributes
          def ensure_sort_descriptor_registered(schema_class)
            return if @sort_descriptor_registered

            has_sortable = schema_class.attribute_definitions.any? { |_, attr| attr.sortable? } ||
                           schema_class.association_definitions.any? { |_, assoc| assoc.sortable? }

            register_sort_descriptor if has_sortable
          end

          # Register a specific filter descriptor (idempotent)
          def register_filter_descriptor(type_name)
            @registered_filter_descriptors ||= Set.new
            return if @registered_filter_descriptors.include?(type_name)

            @registered_filter_descriptors.add(type_name)

            case type_name
            when :string_filter
              register_string_filter
            when :integer_filter
              register_integer_filter_between
              register_integer_filter
            when :decimal_filter
              register_decimal_filter_between
              register_decimal_filter
            when :boolean_filter
              register_boolean_filter
            when :date_filter
              register_date_filter_between
              register_date_filter
            when :datetime_filter
              register_datetime_filter_between
              register_datetime_filter
            when :uuid_filter
              register_uuid_filter
            end
          end

          # Register sort direction enum (idempotent)
          def register_sort_descriptor
            return if @sort_descriptor_registered

            @sort_descriptor_registered = true

            Apiwork.register_descriptors do
              # Sort direction enum
              # Used in all sortable attribute contracts for ordering results
              enum :sort_direction, %w[asc desc]
            end
          end

          private

          # Determine which filter descriptors are needed based on schema's filterable attributes
          def determine_needed_filter_descriptors(schema_class)
            descriptors = Set.new
            schema_class.attribute_definitions.each_value do |attribute_definition|
              next unless attribute_definition.filterable?

              # Use TypeRegistry's logic to determine filter type
              filter_type = Schema::TypeRegistry.determine_filter_type(attribute_definition.type)
              descriptors.add(filter_type)
            end
            descriptors
          end

          # Individual filter descriptor registration methods

          def register_string_filter
            Apiwork.register_descriptors do
              # String filter type
              # Provides common string comparison and pattern matching operators
              type :string_filter do
                param :eq, type: :string, required: false
                param :in, type: :array, of: :string, required: false
                param :contains, type: :string, required: false
                param :starts_with, type: :string, required: false
                param :ends_with, type: :string, required: false
              end
            end
          end

          def register_integer_filter_between
            Apiwork.register_descriptors do
              # Integer range type (for between queries)
              type :integer_filter_between do
                param :from, type: :integer, required: false
                param :to, type: :integer, required: false
              end
            end
          end

          def register_integer_filter
            Apiwork.register_descriptors do
              # Integer filter type
              # Provides numeric comparison operators
              type :integer_filter do
                param :eq, type: :integer, required: false
                param :gt, type: :integer, required: false
                param :gte, type: :integer, required: false
                param :lt, type: :integer, required: false
                param :lte, type: :integer, required: false
                param :in, type: :array, of: :integer, required: false
                param :between, type: :integer_filter_between, required: false
              end
            end
          end

          def register_decimal_filter_between
            Apiwork.register_descriptors do
              # Decimal range type (for between queries)
              type :decimal_filter_between do
                param :from, type: :decimal, required: false
                param :to, type: :decimal, required: false
              end
            end
          end

          def register_decimal_filter
            Apiwork.register_descriptors do
              # Decimal filter type (for decimal, float)
              # Provides numeric comparison operators
              type :decimal_filter do
                param :eq, type: :decimal, required: false
                param :gt, type: :decimal, required: false
                param :gte, type: :decimal, required: false
                param :lt, type: :decimal, required: false
                param :lte, type: :decimal, required: false
                param :in, type: :array, of: :decimal, required: false
                param :between, type: :decimal_filter_between, required: false
              end
            end
          end

          def register_boolean_filter
            Apiwork.register_descriptors do
              # Boolean filter type
              # Simple equality check for booleans
              type :boolean_filter do
                param :eq, type: :boolean, required: false
              end
            end
          end

          def register_date_filter_between
            Apiwork.register_descriptors do
              # Date range type (for between queries)
              type :date_filter_between do
                param :from, type: :string, required: false
                param :to, type: :string, required: false
              end
            end
          end

          def register_date_filter
            Apiwork.register_descriptors do
              # Date filter type
              # Provides date comparison operators
              type :date_filter do
                param :eq, type: :string, required: false
                param :gt, type: :string, required: false
                param :gte, type: :string, required: false
                param :lt, type: :string, required: false
                param :lte, type: :string, required: false
                param :between, type: :date_filter_between, required: false
                param :in, type: :array, of: :string, required: false
              end
            end
          end

          def register_datetime_filter_between
            Apiwork.register_descriptors do
              # Datetime range type (for between queries)
              type :datetime_filter_between do
                param :from, type: :string, required: false
                param :to, type: :string, required: false
              end
            end
          end

          def register_datetime_filter
            Apiwork.register_descriptors do
              # Datetime filter type
              # Provides temporal comparison operators
              type :datetime_filter do
                param :eq, type: :string, required: false
                param :gt, type: :string, required: false
                param :gte, type: :string, required: false
                param :lt, type: :string, required: false
                param :lte, type: :string, required: false
                param :between, type: :datetime_filter_between, required: false
                param :in, type: :array, of: :string, required: false
              end
            end
          end

          def register_uuid_filter
            Apiwork.register_descriptors do
              # UUID filter type
              # Provides UUID comparison operators
              type :uuid_filter do
                param :eq, type: :uuid, required: false
                param :in, type: :array, of: :uuid, required: false
              end
            end
          end
        end

        # Initialize tracking variables
        reset!
      end
    end
  end
end
