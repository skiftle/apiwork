# frozen_string_literal: true

module Apiwork
  module API
    class Descriptors
      def initialize
        @types = Apiwork::Store.new
        @enums = Apiwork::Store.new
      end

      def register_type(name, scope: nil, description: nil, example: nil, format: nil, deprecated: false, &block)
        scoped_name_value = scoped_name(scope, name)
        @types[scoped_name_value] = {
          name:, scoped_name: scoped_name_value, scope:,
          definition: block,
          description:, example:, format:, deprecated:
        }
      end

      def register_union(name, data, scope: nil)
        scoped_name_value = scoped_name(scope, name)
        @types[scoped_name_value] = {
          name:, scoped_name: scoped_name_value, scope:,
          payload: data
        }
      end

      def resolve_type(name, scope: nil)
        if scope
          scoped_name_value = scoped_name(scope, name)
          return @types[scoped_name_value]&.dig(:definition) if @types.key?(scoped_name_value)
        end
        @types[name]&.dig(:definition)
      end

      def type_metadata(name)
        @types[name]
      end

      def scoped_name(scope, name)
        return name unless scope

        prefix = scope.respond_to?(:scope_prefix) ? scope.scope_prefix : nil
        return name unless prefix
        return prefix.to_sym if name.nil? || name.to_s.empty?
        return name.to_sym if name.to_s == prefix

        :"#{prefix}_#{name}"
      end

      def register_enum(name, values, scope: nil, description: nil, example: nil, deprecated: false)
        scoped_name_value = scoped_name(scope, name)
        @enums[scoped_name_value] = {
          name:, scoped_name: scoped_name_value, scope:,
          values:, payload: values, description:, example:, deprecated:
        }
        register_enum_filter_type(name, scoped_name_value, scope:)
      end

      def resolve_enum(name, scope: nil)
        if scope
          scoped_name_value = scoped_name(scope, name)
          return @enums[scoped_name_value]&.dig(:values) if @enums.key?(scoped_name_value)
        end
        @enums[name]&.dig(:values)
      end

      def types_data
        @types
      end

      def enums_data
        @enums
      end

      def clear_expanded_payloads!
        @types.each_value { |meta| meta.delete(:expanded_payload) }
      end

      def clear!
        @types.clear!
        @enums.clear!
      end

      private

      def register_enum_filter_type(enum_name, scoped_enum_name, scope:)
        filter_name = :"#{enum_name}_filter"

        union_data = {
          type: :union,
          required: false,
          nullable: false,
          variants: [
            { type: scoped_enum_name, of: nil },
            { type: :object, of: nil, partial: true, shape: build_enum_filter_shape(scoped_enum_name) }
          ]
        }

        register_union(filter_name, union_data, scope:)
      end

      def build_enum_filter_shape(enum_type)
        {
          eq: { name: :eq, type: enum_type, required: false },
          in: { name: :in, type: :array, of: enum_type, required: false }
        }
      end
    end
  end
end
