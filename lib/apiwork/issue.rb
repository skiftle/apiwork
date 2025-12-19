# frozen_string_literal: true

module Apiwork
  class Issue
    attr_reader :code,
                :detail,
                :meta,
                :path

    def initialize(code:, detail:, path: [], meta: {})
      @code = code
      @detail = detail
      @path = path.map { |element| element.is_a?(Integer) ? element : element.to_sym }
      @meta = meta
    end

    def pointer
      @pointer ||= JSONPointer.new(*path).to_s
    end

    def to_h
      {
        code: code,
        detail: detail,
        path: path.map(&:to_s),
        pointer: pointer,
        meta: meta
      }
    end

    def as_json
      to_h
    end

    def to_s
      "[#{code}]#{path.any? ? " at #{pointer}" : ''} #{detail}"
    end

    def warn
      Rails.logger.warn(to_s)
    end
  end
end
