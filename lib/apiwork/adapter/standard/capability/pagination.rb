# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Capability
        class Pagination < Adapter::Capability::Base
          capability_name :pagination

          option :strategy, default: :offset, enum: %i[offset cursor], type: :symbol
          option :default_size, default: 20, type: :integer
          option :max_size, default: 100, type: :integer

          api API
          contract Contract
          computation Computation
        end
      end
    end
  end
end
