# frozen_string_literal: true

module Apiwork
  class ConstraintError < Error
    attr_reader :issues

    def initialize(issues)
      @issues = Array(issues)
      super(@issues.map(&:detail).join('; '))
    end
  end
end
