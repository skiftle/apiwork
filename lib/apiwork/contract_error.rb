# frozen_string_literal: true

module Apiwork
  class ContractError < ConstraintError
    def layer
      :contract
    end
  end
end
