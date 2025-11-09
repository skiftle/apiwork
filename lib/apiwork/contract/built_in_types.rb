# frozen_string_literal: true

module Apiwork
  module Contract
    # BuiltInTypes: Register Apiwork's built-in global types
    #
    # These types are automatically registered at boot time and are
    # available in all contracts without needing to define them.
    #
    # Categories:
    # 1. Filter types - For filtering collections (string_filter, integer_filter, etc.)
    # 2. Range types - For between queries (integer_between, datetime_between)
    # 3. Utility types - Common types like page_params
    #
    module BuiltInTypes
      def self.register
        Apiwork.register_global_descriptors do
          # String filter type
          # Provides common string comparison and pattern matching operators
          type :string_filter do
            param :eq, type: :string, required: false
            param :in, type: :array, of: :string, required: false
            param :contains, type: :string, required: false
            param :starts_with, type: :string, required: false
            param :ends_with, type: :string, required: false
          end

          # Integer range type (for between queries)
          type :integer_filter_between do
            param :from, type: :integer, required: false
            param :to, type: :integer, required: false
          end

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

          # Decimal range type (for between queries)
          type :decimal_filter_between do
            param :from, type: :decimal, required: false
            param :to, type: :decimal, required: false
          end

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

          # Boolean filter type
          # Simple equality check for booleans
          type :boolean_filter do
            param :eq, type: :boolean, required: false
          end

          # Date range type (for between queries)
          type :date_filter_between do
            param :from, type: :string, required: false
            param :to, type: :string, required: false
          end

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

          # Datetime range type (for between queries)
          type :datetime_filter_between do
            param :from, type: :string, required: false
            param :to, type: :string, required: false
          end

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

          # UUID filter type
          # Provides UUID comparison operators
          type :uuid_filter do
            param :eq, type: :uuid, required: false
            param :in, type: :array, of: :uuid, required: false
          end

          # Pagination parameters
          # Standard pagination with page number and size
          type :page_params do
            param :number, type: :integer, required: false
            param :size, type: :integer, required: false
          end

          # Pagination metadata
          # Standard pagination info returned in collection responses
          type :page do
            param :current, type: :integer, required: true
            param :next, type: :integer, required: false, nullable: true
            param :prev, type: :integer, required: false, nullable: true
            param :total, type: :integer, required: true
            param :items, type: :integer, required: true
          end

          # Error type
          # Standard error structure for API responses
          type :error do
            param :code, type: :string, required: true
            param :field, type: :string, required: false
            param :detail, type: :string, required: false
            param :path, type: :array, of: :string, required: false
          end

          # Global enums - reusable across all contracts

          # Sort direction enum
          # Used in all sortable attribute contracts for ordering results
          enum :sort_direction, %w[asc desc]
        end
      end
    end
  end
end

# Auto-register built-in types at load time
Apiwork::Contract::BuiltInTypes.register
