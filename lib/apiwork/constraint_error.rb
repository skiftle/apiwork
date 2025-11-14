# frozen_string_literal: true

module Apiwork
  class ConstraintError < Error
    USEFUL_META_KEYS = %i[
      attribute in minimum maximum count is too_short too_long
    ].freeze

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

    def dot_path
      @dot_path ||= path.map(&:to_s).join('.')
    end

    def to_h
      filtered = meta.is_a?(Hash) ? meta.slice(*USEFUL_META_KEYS) : meta

      result = {
        code: code,
        path: path.map(&:to_s),
        pointer: pointer,
        detail: message
      }

      result[:options] = filtered if filtered && (filtered.respond_to?(:empty?) ? !filtered.empty? : true)
      result
    end
  end
end
