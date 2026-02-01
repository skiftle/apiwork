# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Capability
        class Filtering
          class APIBuilder < Adapter::Capability::API::Base
            def build
              return unless context.filterable?

              context.filter_types.each { |type| register_filter(type, nullable: false) }
              context.nullable_filter_types.each { |type| register_filter(type, nullable: true) }
            end

            private

            def register_filter(type, nullable:)
              type_name = type_name(type, nullable:)
              return if type?(type_name)

              operators = operators_for(type)
              register_between(type) if operators.include?(:between)

              object(type_name) do |object|
                operators.each { |operator| add_operator(object, operator, type) }
                object.boolean?(:null) if nullable
              end
            end

            def add_operator(object, operator, type)
              case operator
              when :in
                object.array?(:in) { |array| array.of(type) }
              when :between
                object.reference?(:between, to: between_type_name(type))
              else
                object.param(operator, type:, optional: true)
              end
            end

            def register_between(type)
              type_name = between_type_name(type)
              return if type?(type_name)

              object(type_name) do |object|
                object.param(:from, type:, optional: true)
                object.param(:to, type:, optional: true)
              end
            end

            def operators_for(type)
              case type
              when :string, :binary then Constants::STRING_OPERATORS
              when :date, :datetime, :time then Constants::DATE_OPERATORS
              when :integer, :decimal, :number then Constants::NUMERIC_OPERATORS
              when :uuid then Constants::UUID_OPERATORS
              when :boolean then Constants::BOOLEAN_OPERATORS
              else Constants::STRING_OPERATORS
              end
            end

            def type_name(type, nullable:)
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
