# frozen_string_literal: true

module Apiwork
  class ConstraintError < Error
    attr_reader :issues

    def initialize(issues)
      @issues = Array(issues)
      super(@issues.map(&:detail).join('; '))
    end

    def error_code
      @error_code ||= ErrorCode.find!(:bad_request)
    end

    def status
      error_code.status
    end
  end
end
