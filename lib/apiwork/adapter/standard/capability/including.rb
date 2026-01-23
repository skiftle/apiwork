# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Capability
        class Including < Adapter::Capability::Base
          capability_name :including
          input :any

          contract Contract
          result Result
        end
      end
    end
  end
end
