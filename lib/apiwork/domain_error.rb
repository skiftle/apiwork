# frozen_string_literal: true

module Apiwork
  class DomainError < ConstraintError
    def error_code
      @error_code ||= ErrorCode.fetch(:unprocessable_entity)
    end

    def layer
      :domain
    end
  end
end
