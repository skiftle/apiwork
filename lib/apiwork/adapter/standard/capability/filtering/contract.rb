# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Capability
        class Filtering
          class Contract < Adapter::Capability::Contract::Base
            def build
              build_filter_type
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

            def build_filter_type
              return unless filterable_content?

              register_enum_filters

              attribute_filters = collect_attribute_filters
              association_filters = collect_association_filters

              object :filter do
                array? :_and do
                  reference :filter
                end
                array? :_or do
                  reference :filter
                end
                reference? :_not, to: :filter

                attribute_filters.each do |filter|
                  if filter[:union]
                    union? filter[:name] do
                      variant { of(filter[:type]) }
                      variant { reference filter[:filter_type] }
                    end
                  else
                    reference? filter[:name], to: filter[:filter_type]
                  end
                end

                association_filters.each do |filter|
                  reference? filter[:name], to: filter[:filter_type]
                end
              end
            end

            def collect_attribute_filters
              schema_class.attributes.filter_map do |name, attribute|
                next unless attribute.filterable?
                next if attribute.type == :unknown

                filter_type = filter_type_for(attribute)
                use_union = !attribute.enum && !%i[object array union].include?(attribute.type)

                {
                  filter_type:,
                  name:,
                  type: attribute.type,
                  union: use_union,
                }
              end
            end

            def collect_association_filters
              schema_class.associations.filter_map do |name, association|
                next unless association.filterable?

                alias_name = ensure_association_types(association)
                next unless alias_name

                nested_type = :"#{alias_name}_filter"
                next unless type?(nested_type)

                { name:, filter_type: nested_type }
              end
            end

            def register_enum_filters
              schema_class.attributes.each do |name, attribute|
                next unless attribute.filterable? && attribute.enum

                filter_name = :"#{name}_filter"
                next if type?(filter_name)

                scoped_name = scoped_enum_name(name)

                union filter_name do
                  variant { reference scoped_name }
                  variant partial: true do
                    object do
                      reference :eq, to: scoped_name
                      array :in do
                        reference scoped_name
                      end
                    end
                  end
                end
              end
            end

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

            def filterable_content?
              schema_class.attributes.values.any? { |a| a.filterable? && a.type != :unknown } ||
                schema_class.associations.values.any?(&:filterable?)
            end
          end
        end
      end
    end
  end
end
