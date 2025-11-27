# frozen_string_literal: true

module Apiwork
  module Adapter
    class Apiwork < Base
      class DescriptorBuilder
        def self.build(builder, schema_data)
          new(builder, schema_data)
        end

        def initialize(builder, schema_data)
          @builder = builder
          @schema_data = schema_data

          register_base_types
          register_global_filter_types if schema_data.filterable_types.any?
          register_sort_direction if schema_data.sortable?
        end

        private

        attr_reader :builder,
                    :schema_data

        def register_base_types
          builder.instance_eval do
            type :page_pagination do
              param :current, type: :integer, required: true
              param :next, type: :integer, nullable: true
              param :prev, type: :integer, nullable: true
              param :total, type: :integer, required: true
              param :items, type: :integer, required: true
            end

            type :cursor_pagination do
              param :next_cursor, type: :string, nullable: true
              param :prev_cursor, type: :string, nullable: true
            end

            type :issue do
              param :code, type: :string, required: true
              param :field, type: :string, required: true
              param :detail, type: :string, required: true
              param :path, type: :array, of: :string, required: true
            end
          end
        end

        def register_global_filter_types
          filter_types_to_register = Set.new

          # Register non-nullable variants for all filterable types
          schema_data.filterable_types.each do |type|
            filter_type = determine_filter_type(type, nullable: false)
            filter_types_to_register.add(filter_type)
          end

          # Register nullable variants ONLY for types that have nullable attributes
          schema_data.nullable_filterable_types.each do |type|
            nullable_filter_type = determine_filter_type(type, nullable: true)
            filter_types_to_register.add(nullable_filter_type)
          end

          filter_types_to_register.each { |type| register_filter_descriptor(type) }
        end

        def determine_filter_type(attr_type, nullable: false)
          base_type = case attr_type
                      when :string
                        :string_filter
                      when :date
                        :date_filter
                      when :datetime
                        :datetime_filter
                      when :integer
                        :integer_filter
                      when :decimal, :float
                        :decimal_filter
                      when :uuid
                        :uuid_filter
                      when :boolean
                        :boolean_filter
                      else
                        :string_filter
                      end

          nullable ? :"nullable_#{base_type}" : base_type
        end

        def register_sort_direction
          builder.instance_eval do
            enum :sort_direction, values: %w[asc desc]
          end
        end

        def register_filter_descriptor(type_name)
          case type_name
          when :string_filter
            register_string_filter
          when :integer_filter
            register_integer_filter_between
            register_integer_filter
          when :decimal_filter
            register_decimal_filter_between
            register_decimal_filter
          when :boolean_filter
            register_boolean_filter
          when :date_filter
            register_date_filter_between
            register_date_filter
          when :datetime_filter
            register_datetime_filter_between
            register_datetime_filter
          when :uuid_filter
            register_uuid_filter
          when :nullable_string_filter
            register_nullable_string_filter
          when :nullable_integer_filter
            register_integer_filter_between
            register_nullable_integer_filter
          when :nullable_decimal_filter
            register_decimal_filter_between
            register_nullable_decimal_filter
          when :nullable_boolean_filter
            register_nullable_boolean_filter
          when :nullable_date_filter
            register_date_filter_between
            register_nullable_date_filter
          when :nullable_datetime_filter
            register_datetime_filter_between
            register_nullable_datetime_filter
          when :nullable_uuid_filter
            register_nullable_uuid_filter
          else
            # TODO: Switch to adapter-specific error class
            raise ConfigurationError, "Unknown global filter type: #{type_name.inspect}"
          end
        end

        def register_string_filter
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

        def register_integer_filter_between
          builder.instance_eval do
            type :integer_filter_between do
              param :from, type: :integer, required: false
              param :to, type: :integer, required: false
            end
          end
        end

        def register_integer_filter
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

        def register_decimal_filter_between
          builder.instance_eval do
            type :decimal_filter_between do
              param :from, type: :decimal, required: false
              param :to, type: :decimal, required: false
            end
          end
        end

        def register_decimal_filter
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

        def register_boolean_filter
          builder.instance_eval do
            type :boolean_filter do
              param :eq, type: :boolean, required: false
            end
          end
        end

        def register_date_filter_between
          builder.instance_eval do
            type :date_filter_between do
              param :from, type: :date, required: false
              param :to, type: :date, required: false
            end
          end
        end

        def register_date_filter
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

        def register_datetime_filter_between
          builder.instance_eval do
            type :datetime_filter_between do
              param :from, type: :datetime, required: false
              param :to, type: :datetime, required: false
            end
          end
        end

        def register_datetime_filter
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

        def register_uuid_filter
          builder.instance_eval do
            type :uuid_filter do
              param :eq, type: :uuid, required: false
              param :in, type: :array, of: :uuid, required: false
            end
          end
        end

        def register_nullable_string_filter
          builder.instance_eval do
            type :nullable_string_filter do
              param :eq, type: :string, required: false
              param :in, type: :array, of: :string, required: false
              param :contains, type: :string, required: false
              param :starts_with, type: :string, required: false
              param :ends_with, type: :string, required: false
              param :null, type: :boolean, required: false
            end
          end
        end

        def register_nullable_integer_filter
          register_integer_filter_between
          builder.instance_eval do
            type :nullable_integer_filter do
              param :eq, type: :integer, required: false
              param :gt, type: :integer, required: false
              param :gte, type: :integer, required: false
              param :lt, type: :integer, required: false
              param :lte, type: :integer, required: false
              param :in, type: :array, of: :integer, required: false
              param :between, type: :integer_filter_between, required: false
              param :null, type: :boolean, required: false
            end
          end
        end

        def register_nullable_decimal_filter
          register_decimal_filter_between
          builder.instance_eval do
            type :nullable_decimal_filter do
              param :eq, type: :decimal, required: false
              param :gt, type: :decimal, required: false
              param :gte, type: :decimal, required: false
              param :lt, type: :decimal, required: false
              param :lte, type: :decimal, required: false
              param :in, type: :array, of: :decimal, required: false
              param :between, type: :decimal_filter_between, required: false
              param :null, type: :boolean, required: false
            end
          end
        end

        def register_nullable_date_filter
          register_date_filter_between
          builder.instance_eval do
            type :nullable_date_filter do
              param :eq, type: :date, required: false
              param :gt, type: :date, required: false
              param :gte, type: :date, required: false
              param :lt, type: :date, required: false
              param :lte, type: :date, required: false
              param :between, type: :date_filter_between, required: false
              param :in, type: :array, of: :date, required: false
              param :null, type: :boolean, required: false
            end
          end
        end

        def register_nullable_datetime_filter
          register_datetime_filter_between
          builder.instance_eval do
            type :nullable_datetime_filter do
              param :eq, type: :datetime, required: false
              param :gt, type: :datetime, required: false
              param :gte, type: :datetime, required: false
              param :lt, type: :datetime, required: false
              param :lte, type: :datetime, required: false
              param :between, type: :datetime_filter_between, required: false
              param :in, type: :array, of: :datetime, required: false
              param :null, type: :boolean, required: false
            end
          end
        end

        def register_nullable_uuid_filter
          builder.instance_eval do
            type :nullable_uuid_filter do
              param :eq, type: :uuid, required: false
              param :in, type: :array, of: :uuid, required: false
              param :null, type: :boolean, required: false
            end
          end
        end

        def register_nullable_boolean_filter
          builder.instance_eval do
            type :nullable_boolean_filter do
              param :eq, type: :boolean, required: false
              param :null, type: :boolean, required: false
            end
          end
        end
      end
    end
  end
end
