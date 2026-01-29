# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Capability
        class Sorting < Adapter::Capability::Base
          capability_name :sorting

          option :max_depth, default: 2, type: :integer

          api_builder Builder::API
          contract_builder Builder::Contract
          computation Computation
        end
      end
    end
  end
end
