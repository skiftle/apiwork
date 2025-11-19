# frozen_string_literal: true

module Apiwork
  class ConstraintError < Error
    attr_reader :issues

    def initialize(issues)
      @issues = Array(issues)
      super(@issues.map(&:message).join('; '))
    end

    def to_array
      @issues.map(&:to_h)
    end
  end
end
