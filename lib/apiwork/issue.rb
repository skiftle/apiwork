# frozen_string_literal: true

module Apiwork
  class Issue
    attr_reader :code, :path, :meta, :message

    def initialize(code:, message:, path: [], meta: {})
      @code = code
      @path = Array(path).map { |element| element.is_a?(Integer) ? element : element.to_sym }
      @meta = meta
      @message = message
    end

    def pointer
      @pointer ||= JSONPointer.build(*path)
    end

    def to_h
      result = {
        code: code,
        path: path.map(&:to_s),
        pointer: pointer,
        detail: message
      }

      result[:options] = meta if meta.present?
      result
    end

    def as_json
      to_h
    end
  end
end
