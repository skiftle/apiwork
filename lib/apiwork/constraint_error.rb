# frozen_string_literal: true

module Apiwork
  class ConstraintError < Error
    attr_reader :issues

    def initialize(issues)
      @issues = Array(issues)
      super(@issues.map(&:detail).join('; '))
    end

    def http_status
      :bad_request
    end
  end
end
