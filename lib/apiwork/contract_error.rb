# frozen_string_literal: true

module Apiwork
  class ContractError < ConstraintError
    def layer
      :contract
    end

    def error_code
      @error_code ||= ErrorCode.fetch(:bad_request)
    end
  end
end
