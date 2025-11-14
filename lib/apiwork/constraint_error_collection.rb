# frozen_string_literal: true

module Apiwork
  class ConstraintErrorCollection < Error
    attr_reader :errors

    def initialize(errors = [])
      errors = errors.errors if errors.is_a?(ConstraintErrorCollection)

      @errors = Array(errors).map do |error|
        if error.is_a?(ConstraintError)
          error
        else
          ConstraintError.new(
            code: :validation_error,
            message: error.to_s,
            path: []
          )
        end
      end
      super(@errors.map(&:message).join('; '))
    end

    def to_array
      @errors.map(&:to_h)
    end

    def to_h
      { errors: to_array }
    end

    def empty?
      @errors.empty?
    end

    def any?
      @errors.any?
    end

    def <<(error)
      @errors << (if error.is_a?(ConstraintError)
                    error
                  else
                    ConstraintError.new(code: :validation_error,
                                        message: error.to_s, path: [])
                  end)
    end

    def each(&block)
      @errors.each(&block)
    end

    def size
      @errors.size
    end

    def concat(other_errors)
      @errors.concat(Array(other_errors))
    end
  end
end
