# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Capability
        class Filtering
          class Builder
            class API < Adapter::Capability::API::Base
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
                    { name: :in, of: :date, type: :array },
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
                    { name: :in, of: :datetime, type: :array },
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
                    { name: :in, of: :decimal, type: :array },
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
                    { name: :in, of: :integer, type: :array },
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
                    { name: :in, of: :number, type: :array },
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
                    { name: :in, of: :string, type: :array },
                    { name: :contains, type: :string },
                    { name: :starts_with, type: :string },
                    { name: :ends_with, type: :string },
                  ],
                },
                uuid_filter: {
                  params: [
                    { name: :eq, type: :uuid },
                    { name: :in, of: :uuid, type: :array },
                  ],
                },
              }.freeze

              NULLABLE_EXTENSION = { name: :null, type: :boolean }.freeze
              PRIMITIVES = %i[string integer decimal boolean datetime date uuid time binary number].freeze

              def build
                return unless features.filterable?

                filter_types = Set.new
                features.filter_types.each { |type| filter_types.add(determine_filter_type(type, nullable: false)) }
                features.nullable_filter_types.each { |type| filter_types.add(determine_filter_type(type, nullable: true)) }
                filter_types.each { |type| register_filter_type(type) }
              end

              private

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

              def register_filter_type(type_name)
                nullable = type_name.to_s.start_with?('nullable_')
                base_type_name = type_name.to_s.delete_prefix('nullable_').to_sym

                filter_definition = FILTER_DEFINITIONS[base_type_name]
                raise ConfigurationError, "Unknown global filter type: #{type_name.inspect}" unless filter_definition

                register_filter_type(filter_definition[:depends_on]) if filter_definition[:depends_on]

                object(type_name) do |obj|
                  filter_definition[:params].each do |param_options|
                    if param_options[:of]
                      obj.array(param_options[:name], optional: true) do |element|
                        element.of(param_options[:of])
                      end
                    elsif PRIMITIVES.include?(param_options[:type])
                      obj.param(param_options[:name], optional: true, type: param_options[:type])
                    else
                      obj.reference(param_options[:name], optional: true, to: param_options[:type])
                    end
                  end
                  obj.param(:null, optional: true, type: :boolean) if nullable
                end
              end
            end
          end
        end
      end
    end
  end
end
