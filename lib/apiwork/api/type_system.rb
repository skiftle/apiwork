# frozen_string_literal: true

module Apiwork
  module API
    class TypeSystem
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
      end

      def resolve_enum(name, scope: nil)
        if scope
          scoped_name_value = scoped_name(scope, name)
          return @enums[scoped_name_value]&.dig(:values) if @enums.key?(scoped_name_value)
        end
        @enums[name]&.dig(:values)
      end

      attr_reader :enums,
                  :types

      def clear!
        @types.clear!
        @enums.clear!
      end
    end
  end
end
