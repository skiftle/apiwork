# frozen_string_literal: true

module Apiwork
  # @api private
  class ConstraintError < Error
    attr_reader :issues

    def initialize(issues)
      @issues = Array(issues)
      super(@issues.map(&:detail).join('; '))
    end

    def error_code
      @error_code ||= ErrorCode.fetch(:bad_request)
    end
  end
end
