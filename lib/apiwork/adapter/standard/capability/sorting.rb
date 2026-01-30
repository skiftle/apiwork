# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Capability
        class Sorting < Adapter::Capability::Base
          capability_name :sorting

          api_builder APIBuilder
          contract_builder ContractBuilder
          computation Computation
        end
      end
    end
  end
end
