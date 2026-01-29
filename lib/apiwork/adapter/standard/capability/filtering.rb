# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Capability
        class Filtering < Adapter::Capability::Base
          capability_name :filtering

          option :max_depth, default: 3, type: :integer

          api_builder APIBuilder
          contract_builder ContractBuilder
          computation Computation
        end
      end
    end
  end
end
