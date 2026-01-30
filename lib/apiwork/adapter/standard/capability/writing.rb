# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Capability
        class Writing < Adapter::Capability::Base
          capability_name :writing

          request_transformer RequestTransformer
          contract_builder ContractBuilder
          operation Operation
        end
      end
    end
  end
end
