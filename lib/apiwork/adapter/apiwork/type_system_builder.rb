# frozen_string_literal: true

module Apiwork
  module Adapter
    class Apiwork < Base
      class TypeSystemBuilder
        FILTER_DEFINITIONS = {
          string_filter: {
            params: [
              { name: :eq, type: :string },
              { name: :in, type: :array, of: :string },
              { name: :contains, type: :string },
              { name: :starts_with, type: :string },
              { name: :ends_with, type: :string }
            ]
          },
          integer_filter_between: {
            params: [
              { name: :from, type: :integer },
              { name: :to, type: :integer }
            ]
          },
          integer_filter: {
            depends_on: :integer_filter_between,
            params: [
              { name: :eq, type: :integer },
              { name: :gt, type: :integer },
              { name: :gte, type: :integer },
              { name: :lt, type: :integer },
              { name: :lte, type: :integer },
              { name: :in, type: :array, of: :integer },
              { name: :between, type: :integer_filter_between }
            ]
          },
          decimal_filter_between: {
            params: [
              { name: :from, type: :decimal },
              { name: :to, type: :decimal }
            ]
          },
          decimal_filter: {
            depends_on: :decimal_filter_between,
            params: [
              { name: :eq, type: :decimal },
              { name: :gt, type: :decimal },
              { name: :gte, type: :decimal },
              { name: :lt, type: :decimal },
              { name: :lte, type: :decimal },
              { name: :in, type: :array, of: :decimal },
              { name: :between, type: :decimal_filter_between }
            ]
          },
          boolean_filter: {
            params: [
              { name: :eq, type: :boolean }
            ]
          },
          date_filter_between: {
            params: [
              { name: :from, type: :date },
              { name: :to, type: :date }
            ]
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
              { name: :in, type: :array, of: :date }
            ]
          },
          datetime_filter_between: {
            params: [
              { name: :from, type: :datetime },
              { name: :to, type: :datetime }
            ]
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
              { name: :in, type: :array, of: :datetime }
            ]
          },
          uuid_filter: {
            params: [
              { name: :eq, type: :uuid },
              { name: :in, type: :array, of: :uuid }
            ]
          }
        }.freeze

        NULLABLE_EXTENSION = { name: :null, type: :boolean }.freeze

        def self.build(type_registrar, schema_data)
          new(type_registrar, schema_data)
        end

        def initialize(type_registrar, schema_data)
          @type_registrar = type_registrar
          @schema_data = schema_data

          register_pagination_types if schema_data.has_index_actions?
          register_issue_type if schema_data.has_resources?
          register_global_filter_types if schema_data.filterable_types.any?
          register_sort_direction if schema_data.sortable?
        end

        private

        attr_reader :type_registrar,
                    :schema_data

        def register_pagination_types
          register_page_pagination if schema_data.uses_page_pagination?
          register_cursor_pagination if schema_data.uses_cursor_pagination?
        end

        def register_page_pagination
          type_registrar.type :page_pagination do
            param :current, type: :integer, required: true
            param :next, type: :integer, nullable: true
            param :prev, type: :integer, nullable: true
            param :total, type: :integer, required: true
            param :items, type: :integer, required: true
          end
        end

        def register_cursor_pagination
          type_registrar.type :cursor_pagination do
            param :next_cursor, type: :string, nullable: true
            param :prev_cursor, type: :string, nullable: true
          end
        end

        def register_issue_type
          type_registrar.type :issue do
            param :code, type: :string, required: true
            param :field, type: :string, required: true
            param :detail, type: :string, required: true
            param :path, type: :array, of: :string, required: true
          end
        end

        def register_global_filter_types
          filter_types_to_register = Set.new

          schema_data.filterable_types.each do |type|
            filter_types_to_register.add(determine_filter_type(type, nullable: false))
          end

          schema_data.nullable_filterable_types.each do |type|
            filter_types_to_register.add(determine_filter_type(type, nullable: true))
          end

          filter_types_to_register.each { |type| register_filter_type(type) }
        end

        def determine_filter_type(attr_type, nullable: false)
          base_type = case attr_type
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
          type_registrar.enum :sort_direction, values: %w[asc desc]
        end

        def register_filter_type(type_name)
          base_type_name = type_name.to_s.delete_prefix('nullable_').to_sym
          nullable = type_name.to_s.start_with?('nullable_')

          definition = FILTER_DEFINITIONS[base_type_name]
          raise ConfigurationError, "Unknown global filter type: #{type_name.inspect}" unless definition

          register_filter_type(definition[:depends_on]) if definition[:depends_on]

          params = definition[:params].dup
          params << NULLABLE_EXTENSION if nullable

          type_registrar.type(type_name) do
            params.each do |param_def|
              if param_def[:of]
                param param_def[:name], type: param_def[:type], of: param_def[:of], required: false
              else
                param param_def[:name], type: param_def[:type], required: false
              end
            end
          end
        end
      end
    end
  end
end
