# frozen_string_literal: true

module Apiwork
  class DomainError < ConstraintError
    def layer
      :domain
    end

    def error_code
      @error_code ||= ErrorCode.find!(:unprocessable_entity)
    end
  end
end
