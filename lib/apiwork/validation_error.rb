# frozen_string_literal: true

module Apiwork
  # @api private
  class ValidationError < ConstraintError
    def error_code
      @error_code ||= ErrorCode.fetch(:unprocessable_entity)
    end
  end
end
