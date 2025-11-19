# frozen_string_literal: true

module Apiwork
  class ValidationError < ConstraintError
    def http_status
      :unprocessable_entity
    end
  end
end
