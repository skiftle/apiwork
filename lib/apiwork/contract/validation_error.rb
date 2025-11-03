# frozen_string_literal: true

module Apiwork
  module Contract
    # Standardized validation error for Contract system
    # Provides consistent error structure across all contract validation
    # Inherits from StandardError so it can be raised as an exception
    class ValidationError < StandardError
      attr_reader :code, :field, :detail, :path, :meta

      def initialize(code:, field: nil, detail:, path: [], **meta)
        @code = code
        @field = field
        @detail = detail
        @path = Array(path)
        @meta = meta

        # Set exception message to the detail text
        super(detail)
      end

      def pointer
        @pointer ||= Apiwork::Errors::JSONPointer.build(*path)
      end

      def to_h
        {
          code: code,
          field: field,
          detail: detail,
          path: path.map(&:to_s),
          pointer: pointer
        }.merge(@meta.slice(:expected, :actual, :allowed, :depth, :max_depth, :expected_type, :actual_value))
      end

      # Factory methods for standard error types
      class << self
        def field_unknown(field:, allowed:, path: [])
          new(
            code: :field_unknown,
            field: field,
            detail: "Unknown field",
            path: path,
            allowed: allowed
          )
        end

        def field_missing(field:, path: [])
          new(
            code: :field_missing,
            field: field,
            detail: "Field required",
            path: path
          )
        end

        def invalid_type(field:, expected:, actual:, path: [])
          new(
            code: :invalid_type,
            field: field,
            detail: "Invalid type",
            path: path,
            expected: expected,
            actual: actual
          )
        end

        def invalid_association(field:, association_type:, path: [])
          new(
            code: :invalid_association,
            field: field,
            detail: "Invalid value",
            path: path,
            expected: association_type
          )
        end

        def value_null(field:, path: [])
          new(
            code: :value_null,
            field: field,
            detail: "Value cannot be null",
            path: path
          )
        end

        def max_depth_exceeded(depth:, max_depth:, path: [])
          new(
            code: :max_depth_exceeded,
            detail: "Max depth exceeded",
            path: path,
            depth: depth,
            max_depth: max_depth
          )
        end

        def circular_reference(resource_class:, path: [])
          new(
            code: :circular_reference,
            detail: "Circular reference",
            path: path,
            resource_class: resource_class.to_s
          )
        end

        def array_too_large(size:, max_size:, path: [])
          new(
            code: :array_too_large,
            detail: "Value too large",
            path: path,
            size: size,
            max_size: max_size
          )
        end

        def invalid_array_element(index:, field:, expected:, actual:, path: [])
          new(
            code: :invalid_type,
            field: field,
            detail: "Invalid type",
            path: path + [index],
            expected: expected,
            actual: actual
          )
        end

        def coercion_failed(field:, type:, value:, path: [])
          # Truncate value to reasonable length for error messages
          truncated_value = value.to_s.length > 100 ? "#{value.to_s[0...100]}..." : value.to_s

          new(
            code: :coercion_failed,
            field: field,
            detail: "Could not parse value as #{type}",
            path: path,
            expected_type: type,
            actual_value: truncated_value
          )
        end
      end
    end
  end
end
