# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      class TypeSystemBuilder
        FILTER_DEFINITIONS = {
          boolean_filter: {
            params: [
              { name: :eq, type: :boolean },
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
          date_filter_between: {
            params: [
              { name: :from, type: :date },
              { name: :to, type: :date },
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
          datetime_filter_between: {
            params: [
              { name: :from, type: :datetime },
              { name: :to, type: :datetime },
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
          decimal_filter_between: {
            params: [
              { name: :from, type: :decimal },
              { name: :to, type: :decimal },
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
          integer_filter_between: {
            params: [
              { name: :from, type: :integer },
              { name: :to, type: :integer },
            ],
          },
          number_filter: {
            depends_on: :number_filter_between,
            params: [
              { name: :eq, type: :number },
              { name: :gt, type: :number },
              { name: :gte, type: :number },
              { name: :lt, type: :number },
              { name: :lte, type: :number },
              {
                name: :in,
                of: :number,
                type: :array,
              },
              { name: :between, type: :number_filter_between },
            ],
          },
          number_filter_between: {
            params: [
              { name: :from, type: :number },
              { name: :to, type: :number },
            ],
          },
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

        def self.build(registrar, capabilities)
          new(registrar, capabilities)
        end

        def initialize(registrar, capabilities)
          @registrar = registrar
          @capabilities = capabilities

          register_pagination_types if capabilities.index_actions?
          register_error_type if capabilities.resources?
          register_global_filter_types if capabilities.filter_types.any?
          register_sort_direction if capabilities.sortable?
        end

        private

        attr_reader :capabilities,
                    :registrar

        def register_pagination_types
          strategies = capabilities.options_for(:pagination, :strategy)
          register_offset_pagination if strategies.include?(:offset)
          register_cursor_pagination if strategies.include?(:cursor)
        end

        def register_offset_pagination
          registrar.object :offset_pagination do
            integer :current
            integer :next, nullable: true, optional: true
            integer :prev, nullable: true, optional: true
            integer :total
            integer :items
          end
        end

        def register_cursor_pagination
          registrar.object :cursor_pagination do
            string :next, nullable: true, optional: true
            string :prev, nullable: true, optional: true
          end
        end

        def register_error_type
          registrar.enum :layer, values: %w[http contract domain]

          registrar.object :issue do
            string :code
            string :detail
            array :path do
              string
            end
            string :pointer
            object :meta
          end

          registrar.object :error_response_body do
            reference :layer
            array :issues do
              reference :issue
            end
          end
        end

        def register_global_filter_types
          filter_types_to_register = Set.new

          capabilities.filter_types.each do |type|
            filter_types_to_register.add(determine_filter_type(type, nullable: false))
          end

          capabilities.nullable_filter_types.each do |type|
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
                      when :decimal then :decimal_filter
                      when :number then :number_filter
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

          primitives = %i[string integer decimal boolean datetime date uuid time binary float]

          registrar.object(type_name) do
            params.each do |param_definition|
              name = param_definition[:name]
              type = param_definition[:type]
              element_type = param_definition[:of]

              if element_type
                array name, optional: true do
                  send(element_type)
                end
              elsif primitives.include?(type)
                send(type, name, optional: true)
              else
                reference name, optional: true, to: type
              end
            end
          end
        end
      end
    end
  end
end
