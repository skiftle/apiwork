# frozen_string_literal: true

module Apiwork
  # @api public
  # Represents a validation issue found during request parsing.
  #
  # Issues are returned when request parameters fail validation,
  # coercion, or constraint checks. Access via `contract.issues`.
  class Issue
    # @api public
    # The error code (e.g., :required, :type_mismatch).
    # @return [Symbol]
    attr_reader :code

    # @api public
    # Human-readable error message.
    # @return [String]
    attr_reader :detail

    # @api public
    # Additional context about the error.
    # @return [Hash]
    attr_reader :meta

    # @api public
    # Path to the invalid field.
    # @return [Array<Symbol, Integer>]
    attr_reader :path

    def initialize(code, detail, meta: {}, path: [])
      @code = code
      @detail = detail
      @path = path.map { |element| element.is_a?(Integer) ? element : element.to_sym }
      @meta = meta
    end

    # @api public
    # The JSON pointer for this issue.
    #
    # @return [String]
    def pointer
      @pointer ||= JSONPointer.new(*path).to_s
    end

    # @api public
    # Converts this issue to a hash.
    #
    # @return [Hash]
    def to_h
      {
        code: code,
        detail: detail,
        meta: meta,
        path: path.map(&:to_s),
        pointer: pointer,
      }
    end

    # @api public
    # Alias for to_h, for JSON serialization.
    # @return [Hash]
    def as_json
      to_h
    end

    # @api public
    # Human-readable string representation.
    # @return [String]
    def to_s
      "[#{code}]#{path.any? ? " at #{pointer}" : ''} #{detail}"
    end
  end
end
