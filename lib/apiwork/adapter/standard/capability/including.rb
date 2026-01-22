# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Capability
        class Including < Adapter::Capability::Base
          capability_name :including
          input :any

          contract_builder ContractBuilder
          data_applier DataApplier
        end
      end
    end
  end
end
