# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Capability
        class Filtering
          class Contract < Adapter::Capability::Contract::Base
            def build
              return unless filterable?

              schema_class.attributes.each do |name, attribute|
                next unless attribute.filterable? && attribute.enum
                next if type?(:"#{name}_filter")

                scoped = scoped_enum_name(name)

                union :"#{name}_filter" do
                  variant { reference scoped }
                  variant partial: true do
                    object do
                      reference :eq, to: scoped
                      array(:in) { reference scoped }
                    end
                  end
                end
              end

              attributes = schema_class.attributes.filter_map do |name, attribute|
                next unless attribute.filterable? && attribute.type != :unknown

                filter_type = filter_type_for(attribute)
                shorthand = !attribute.enum && !%i[object array union].include?(attribute.type)
                [name, attribute.type, filter_type, shorthand]
              end

              associations = schema_class.associations.filter_map do |name, association|
                next unless association.filterable?
                next if association.polymorphic?

                schema = association.schema_class
                next unless schema

                contract = find_contract_for_schema(schema)
                next unless contract

                alias_name = schema.root_key.singular.to_sym
                import(contract, as: alias_name)

                filter_type = :"#{alias_name}_filter"
                next unless type?(filter_type)

                [name, filter_type]
              end

              object :filter do
                array? Constants::AND do
                  reference :filter
                end
                array? Constants::OR do
                  reference :filter
                end
                reference? Constants::NOT, to: :filter

                attributes.each do |name, type, filter_type, shorthand|
                  if shorthand
                    union? name do
                      variant { of(type) }
                      variant { reference filter_type }
                    end
                  else
                    reference? name, to: filter_type
                  end
                end

                associations.each do |name, filter_type|
                  reference? name, to: filter_type
                end
              end

              return unless type?(:filter)

              action :index do
                request do
                  query do
                    union? :filter do
                      variant { reference :filter }
                      variant { array { reference :filter } }
                    end
                  end
                end
              end
            end

            private

            def filter_type_for(attribute)
              return :"#{attribute.name}_filter" if attribute.enum

              base = case attribute.type
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

              attribute.nullable? ? :"nullable_#{base}" : base
            end

            def filterable?
              schema_class.attributes.values.any? { |a| a.filterable? && a.type != :unknown } ||
                schema_class.associations.values.any?(&:filterable?)
            end
          end
        end
      end
    end
  end
end
