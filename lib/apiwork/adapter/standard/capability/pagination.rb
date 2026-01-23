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

          shape do
            reference :pagination, to: (options.strategy == :cursor ? :cursor_pagination : :offset_pagination)
          end

          api API
          contract Contract
          computation Computation

          # each_bound_contract do |context|
          # end
        end
      end
    end
  end
end
