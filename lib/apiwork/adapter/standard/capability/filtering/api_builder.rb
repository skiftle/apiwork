# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Capability
        class Filtering
          class APIBuilder < Adapter::Capability::API::Base
            def build
              return unless features.filterable?

              features.filter_types.each { |type| register_filter(type, nullable: false) }
              features.nullable_filter_types.each { |type| register_filter(type, nullable: true) }
            end

            private

            def register_filter(type, nullable:)
              type_name = filter_type_name(type, nullable:)
              return if type?(type_name)

              operators = operators_for(type)
              register_between_type(type) if operators.include?(:between)

              object(type_name) do |obj|
                operators.each { |operator| add_operator(obj, operator, type) }
                obj.param(:null, optional: true, type: :boolean) if nullable
              end
            end

            def add_operator(obj, operator, type)
              case operator
              when :in
                obj.array(:in, optional: true) { |element| element.of(type) }
              when :between
                obj.reference(:between, optional: true, to: between_type_name(type))
              else
                obj.param(operator, type:, optional: true)
              end
            end

            def register_between_type(type)
              type_name = between_type_name(type)
              return if type?(type_name)

              object(type_name) do |obj|
                obj.param(:from, type:, optional: true)
                obj.param(:to, type:, optional: true)
              end
            end

            def operators_for(type)
              case type
              when :string then Constants::STRING_OPERATORS
              when :date, :datetime then Constants::DATE_OPERATORS
              when :integer, :decimal, :number then Constants::NUMERIC_OPERATORS
              when :uuid then Constants::UUID_OPERATORS
              when :boolean then Constants::BOOLEAN_OPERATORS
              else Constants::STRING_OPERATORS
              end
            end

            def filter_type_name(type, nullable:)
              nullable ? [:nullable, type, :filter].join('_').to_sym : [type, :filter].join('_').to_sym
            end

            def between_type_name(type)
              [type, :filter, :between].join('_').to_sym
            end
          end
        end
      end
    end
  end
end
