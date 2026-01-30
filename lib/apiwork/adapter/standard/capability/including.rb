# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Capability
        class Including < Adapter::Capability::Base
          capability_name :including

          contract_builder ContractBuilder
          operation Operation
        end
      end
    end
  end
end
