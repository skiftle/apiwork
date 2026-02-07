# frozen_string_literal: true

module Apiwork
  # @api public
  # Represents a validation issue found during request parsing.
  #
  # Issues are returned when request parameters fail validation,
  # coercion, or constraint checks. Access via `contract.issues`.
  class Issue
    # @api public
    # @return [Symbol]
    attr_reader :code

    # @api public
    # @return [String]
    attr_reader :detail

    # @api public
    # @return [Hash]
    attr_reader :meta

    # @api public
    # @return [Array<Symbol, Integer>]
    attr_reader :path

    def initialize(code, detail, meta: {}, path: [])
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
    # @return [Hash]
    def as_json
      to_h
    end

    # @api public
    # @return [String]
    def to_s
      "[#{code}]#{path.any? ? " at #{pointer}" : ''} #{detail}"
    end
  end
end
