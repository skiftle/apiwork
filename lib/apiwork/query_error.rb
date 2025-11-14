# frozen_string_literal: true

module Apiwork
  class QueryError < Error
    attr_reader :code, :path, :meta

    def initialize(code:, message:, path: [], meta: {})
      @code = code
      @path = Array(path).map { |element| element.is_a?(Integer) ? element : element.to_sym }
      @meta = meta
      super(message)
    end

    def pointer
      @pointer ||= Errors::JSONPointer.build(*path)
    end

    def to_h
      {
        code: code,
        path: path.map(&:to_s),
        pointer: pointer,
        detail: message
      }
    end
  end
end
