# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Capability
        class Including < Adapter::Capability::Base
          capability_name :including

          contract_builder Builder::Contract
          computation Computation
        end
      end
    end
  end
end
