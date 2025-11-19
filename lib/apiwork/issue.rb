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
      filtered_meta = meta.is_a?(Hash) ? meta.slice(:attribute, :in, :minimum, :maximum, :count, :is, :too_short, :too_long) : meta

      result = {
        code: code,
        path: path.map(&:to_s),
        pointer: pointer,
        detail: message
      }

      result[:options] = filtered_meta if filtered_meta && (filtered_meta.respond_to?(:empty?) ? filtered_meta.present? : true)
      result
    end

    def as_json
      to_h
    end
  end
end
