# frozen_string_literal: true

module Apiwork
  # @api public
  # Represents a validation issue found during request parsing.
  #
  # Issues are returned when request parameters fail validation,
  # coercion, or constraint checks. Access via `contract.issues`.
  class Issue
    # @api public
    # @return [Symbol] the error code (e.g., :required, :type_mismatch)
    attr_reader :code

    # @api public
    # @return [String] human-readable error message
    attr_reader :detail

    # @api public
    # @return [Hash] additional context about the error
    attr_reader :meta

    # @api public
    # @return [Array<Symbol, Integer>] path to the invalid field
    attr_reader :path

    def initialize(code:, detail:, path: [], meta: {})
      @code = code
      @detail = detail
      @path = path.map { |element| element.is_a?(Integer) ? element : element.to_sym }
      @meta = meta
    end

    # @api public
    # @return [String] JSON Pointer to the invalid field (e.g., "/user/email")
    def pointer
      @pointer ||= JSONPointer.new(*path).to_s
    end

    # @api public
    # @return [Hash] hash representation with code, detail, path, pointer, meta
    def to_h
      {
        code: code,
        detail: detail,
        path: path.map(&:to_s),
        pointer: pointer,
        meta: meta
      }
    end

    # @api public
    # @return [Hash] alias for to_h, for JSON serialization
    def as_json
      to_h
    end

    # @api public
    # @return [String] human-readable string representation
    def to_s
      "[#{code}]#{path.any? ? " at #{pointer}" : ''} #{detail}"
    end
  end
end
