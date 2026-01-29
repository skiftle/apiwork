# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Capability
        class Writing < Adapter::Capability::Base
          capability_name :writing

          request_transformer OpFieldTransformer, post: true

          contract_builder ContractBuilder
          computation Computation
        end
      end
    end
  end
end
