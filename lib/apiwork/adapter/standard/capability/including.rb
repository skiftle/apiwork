# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Capability
        class Including < Adapter::Capability::Base
          capability_name :including
          input :any

          contract ContractBuilder
          apply_data DataApplier
        end
      end
    end
  end
end
