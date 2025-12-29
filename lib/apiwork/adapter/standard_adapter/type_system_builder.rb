# frozen_string_literal: true

module Apiwork
  module Adapter
    class StandardAdapter < Base
      class TypeSystemBuilder
        FILTER_DEFINITIONS = {
          string_filter: {
            params: [
              { name: :eq, type: :string },
              {
                name: :in,
                of: :string,
                type: :array,
              },
              { name: :contains, type: :string },
              { name: :starts_with, type: :string },
              { name: :ends_with, type: :string },
            ],
          },
          integer_filter_between: {
            params: [
              { name: :from, type: :integer },
              { name: :to, type: :integer },
            ],
          },
          integer_filter: {
            depends_on: :integer_filter_between,
            params: [
              { name: :eq, type: :integer },
              { name: :gt, type: :integer },
              { name: :gte, type: :integer },
              { name: :lt, type: :integer },
              { name: :lte, type: :integer },
              {
                name: :in,
                of: :integer,
                type: :array,
              },
              { name: :between, type: :integer_filter_between },
            ],
          },
          decimal_filter_between: {
            params: [
              { name: :from, type: :decimal },
              { name: :to, type: :decimal },
            ],
          },
          decimal_filter: {
            depends_on: :decimal_filter_between,
            params: [
              { name: :eq, type: :decimal },
              { name: :gt, type: :decimal },
              { name: :gte, type: :decimal },
              { name: :lt, type: :decimal },
              { name: :lte, type: :decimal },
              {
                name: :in,
                of: :decimal,
                type: :array,
              },
              { name: :between, type: :decimal_filter_between },
            ],
          },
          boolean_filter: {
            params: [
              { name: :eq, type: :boolean },
            ],
          },
          date_filter_between: {
            params: [
              { name: :from, type: :date },
              { name: :to, type: :date },
            ],
          },
          date_filter: {
            depends_on: :date_filter_between,
            params: [
              { name: :eq, type: :date },
              { name: :gt, type: :date },
              { name: :gte, type: :date },
              { name: :lt, type: :date },
              { name: :lte, type: :date },
              { name: :between, type: :date_filter_between },
              {
                name: :in,
                of: :date,
                type: :array,
              },
            ],
          },
          datetime_filter_between: {
            params: [
              { name: :from, type: :datetime },
              { name: :to, type: :datetime },
            ],
          },
          datetime_filter: {
            depends_on: :datetime_filter_between,
            params: [
              { name: :eq, type: :datetime },
              { name: :gt, type: :datetime },
              { name: :gte, type: :datetime },
              { name: :lt, type: :datetime },
              { name: :lte, type: :datetime },
              { name: :between, type: :datetime_filter_between },
              {
                name: :in,
                of: :datetime,
                type: :array,
              },
            ],
          },
          uuid_filter: {
            params: [
              { name: :eq, type: :uuid },
              {
                name: :in,
                of: :uuid,
                type: :array,
              },
            ],
          },
        }.freeze

        NULLABLE_EXTENSION = { name: :null, type: :boolean }.freeze

        def self.build(registrar, schema_summary)
          new(registrar, schema_summary)
        end

        def initialize(registrar, schema_summary)
          @registrar = registrar
          @schema_summary = schema_summary

          register_pagination_types if schema_summary.has_index_actions?
          register_error_type if schema_summary.has_resources?
          register_global_filter_types if schema_summary.filterable_types.any?
          register_sort_direction if schema_summary.sortable?
        end

        private

        attr_reader :registrar,
                    :schema_summary

        def register_pagination_types
          register_offset_pagination if schema_summary.uses_offset_pagination?
          register_cursor_pagination if schema_summary.uses_cursor_pagination?
        end

        def register_offset_pagination
          registrar.type :offset_pagination do
            param :current, type: :integer
            param :next,
                  nullable: true,
                  optional: true,
                  type: :integer
            param :prev,
                  nullable: true,
                  optional: true,
                  type: :integer
            param :total, type: :integer
            param :items, type: :integer
          end
        end

        def register_cursor_pagination
          registrar.type :cursor_pagination do
            param :next,
                  nullable: true,
                  optional: true,
                  type: :string
            param :prev,
                  nullable: true,
                  optional: true,
                  type: :string
          end
        end

        def register_error_type
          registrar.enum :layer, values: %w[http contract domain]

          registrar.type :issue do
            param :code, type: :string
            param :detail, type: :string
            param :path, of: :string, type: :array
            param :pointer, type: :string
            param :meta, type: :object
          end

          registrar.type :error_response_body do
            param :layer, type: :layer
            param :issues, of: :issue, type: :array
          end
        end

        def register_global_filter_types
          filter_types_to_register = Set.new

          schema_summary.filterable_types.each do |type|
            filter_types_to_register.add(determine_filter_type(type, nullable: false))
          end

          schema_summary.nullable_filterable_types.each do |type|
            filter_types_to_register.add(determine_filter_type(type, nullable: true))
          end

          filter_types_to_register.each { |type| register_filter_type(type) }
        end

        def determine_filter_type(attribute_type, nullable: false)
          base_type = case attribute_type
                      when :string then :string_filter
                      when :date then :date_filter
                      when :datetime then :datetime_filter
                      when :integer then :integer_filter
                      when :decimal, :float then :decimal_filter
                      when :uuid then :uuid_filter
                      when :boolean then :boolean_filter
                      else :string_filter
                      end

          nullable ? :"nullable_#{base_type}" : base_type
        end

        def register_sort_direction
          registrar.enum :sort_direction, values: %w[asc desc]
        end

        def register_filter_type(type_name)
          base_type_name = type_name.to_s.delete_prefix('nullable_').to_sym
          nullable = type_name.to_s.start_with?('nullable_')

          definition = FILTER_DEFINITIONS[base_type_name]
          raise ConfigurationError, "Unknown global filter type: #{type_name.inspect}" unless definition

          register_filter_type(definition[:depends_on]) if definition[:depends_on]

          params = definition[:params].dup
          params << NULLABLE_EXTENSION if nullable

          registrar.type(type_name) do
            params.each do |param_definition|
              if param_definition[:of]
                param param_definition[:name],
                      of: param_definition[:of],
                      optional: true,
                      type: param_definition[:type]
              else
                param param_definition[:name], optional: true, type: param_definition[:type]
              end
            end
          end
        end
      end
    end
  end
end
