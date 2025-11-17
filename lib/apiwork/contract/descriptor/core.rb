# frozen_string_literal: true

module Apiwork
  module Contract
    module Descriptor
      module Core
        class << self
          def clear!
            @api_registered_filter_descriptors = {}
            @api_sort_descriptor_registered = {}
          end

          def register_core_descriptors(api_class)
            builder = Builder.new(api_class: api_class)
            builder.instance_eval do
              type :pagination do
                param :current, type: :integer, required: true
                param :next, type: :integer, nullable: true
                param :prev, type: :integer, nullable: true
                param :total, type: :integer, required: true
                param :items, type: :integer, required: true
              end

              type :issue do
                param :code, type: :string, required: true
                param :field, type: :string, required: true
                param :detail, type: :string, required: true
                param :path, type: :array, of: :string, required: true
              end
            end
          end

          def ensure_filter_descriptors_registered(schema_class, api_class:)
            needed = determine_needed_filter_descriptors(schema_class)
            needed.each { |type| register_filter_descriptor(type, api_class: api_class) }
          end

          def ensure_sort_descriptor_registered(schema_class, api_class:)
            @api_sort_descriptor_registered ||= {}
            return if @api_sort_descriptor_registered[api_class]

            has_attributes_sortable = schema_class.attribute_definitions.values.any?(&:sortable?)
            has_associations_sortable = schema_class.association_definitions.values.any?(&:sortable?)

            has_sortable = has_attributes_sortable || has_associations_sortable

            register_sort_descriptor(api_class: api_class) if has_sortable
          end

          def register_filter_descriptor(type_name, api_class:)
            @api_registered_filter_descriptors ||= {}
            @api_registered_filter_descriptors[api_class] ||= Set.new
            return if @api_registered_filter_descriptors[api_class].include?(type_name)

            @api_registered_filter_descriptors[api_class].add(type_name)

            case type_name
            when :string_filter
              register_string_filter(api_class: api_class)
            when :integer_filter
              register_integer_filter_between(api_class: api_class)
              register_integer_filter(api_class: api_class)
            when :decimal_filter
              register_decimal_filter_between(api_class: api_class)
              register_decimal_filter(api_class: api_class)
            when :boolean_filter
              register_boolean_filter(api_class: api_class)
            when :date_filter
              register_date_filter_between(api_class: api_class)
              register_date_filter(api_class: api_class)
            when :datetime_filter
              register_datetime_filter_between(api_class: api_class)
              register_datetime_filter(api_class: api_class)
            when :uuid_filter
              register_uuid_filter(api_class: api_class)
            end
          end

          def register_sort_descriptor(api_class:)
            @api_sort_descriptor_registered ||= {}
            return if @api_sort_descriptor_registered[api_class]

            @api_sort_descriptor_registered[api_class] = true

            builder = Builder.new(api_class: api_class)
            builder.instance_eval do
              enum :sort_direction, %w[asc desc]
            end
          end

          private

          def determine_needed_filter_descriptors(schema_class)
            descriptors = Set.new
            schema_class.attribute_definitions.each_value do |attribute_definition|
              next unless attribute_definition.filterable?

              filter_type = Schema::TypeRegistry.determine_filter_type(attribute_definition.type)
              descriptors.add(filter_type)
            end
            descriptors
          end

          def register_string_filter(api_class:)
            builder = Builder.new(api_class: api_class)
            builder.instance_eval do
              type :string_filter do
                param :eq, type: :string, required: false
                param :in, type: :array, of: :string, required: false
                param :contains, type: :string, required: false
                param :starts_with, type: :string, required: false
                param :ends_with, type: :string, required: false
              end
            end
          end

          def register_integer_filter_between(api_class:)
            builder = Builder.new(api_class: api_class)
            builder.instance_eval do
              type :integer_filter_between do
                param :from, type: :integer, required: false
                param :to, type: :integer, required: false
              end
            end
          end

          def register_integer_filter(api_class:)
            builder = Builder.new(api_class: api_class)
            builder.instance_eval do
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

          def register_decimal_filter_between(api_class:)
            builder = Builder.new(api_class: api_class)
            builder.instance_eval do
              type :decimal_filter_between do
                param :from, type: :decimal, required: false
                param :to, type: :decimal, required: false
              end
            end
          end

          def register_decimal_filter(api_class:)
            builder = Builder.new(api_class: api_class)
            builder.instance_eval do
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

          def register_boolean_filter(api_class:)
            builder = Builder.new(api_class: api_class)
            builder.instance_eval do
              type :boolean_filter do
                param :eq, type: :boolean, required: false
              end
            end
          end

          def register_date_filter_between(api_class:)
            builder = Builder.new(api_class: api_class)
            builder.instance_eval do
              type :date_filter_between do
                param :from, type: :date, required: false
                param :to, type: :date, required: false
              end
            end
          end

          def register_date_filter(api_class:)
            builder = Builder.new(api_class: api_class)
            builder.instance_eval do
              type :date_filter do
                param :eq, type: :date, required: false
                param :gt, type: :date, required: false
                param :gte, type: :date, required: false
                param :lt, type: :date, required: false
                param :lte, type: :date, required: false
                param :between, type: :date_filter_between, required: false
                param :in, type: :array, of: :date, required: false
              end
            end
          end

          def register_datetime_filter_between(api_class:)
            builder = Builder.new(api_class: api_class)
            builder.instance_eval do
              type :datetime_filter_between do
                param :from, type: :datetime, required: false
                param :to, type: :datetime, required: false
              end
            end
          end

          def register_datetime_filter(api_class:)
            builder = Builder.new(api_class: api_class)
            builder.instance_eval do
              type :datetime_filter do
                param :eq, type: :datetime, required: false
                param :gt, type: :datetime, required: false
                param :gte, type: :datetime, required: false
                param :lt, type: :datetime, required: false
                param :lte, type: :datetime, required: false
                param :between, type: :datetime_filter_between, required: false
                param :in, type: :array, of: :datetime, required: false
              end
            end
          end

          def register_uuid_filter(api_class:)
            builder = Builder.new(api_class: api_class)
            builder.instance_eval do
              type :uuid_filter do
                param :eq, type: :uuid, required: false
                param :in, type: :array, of: :uuid, required: false
              end
            end
          end
        end

        clear!
      end
    end
  end
end
