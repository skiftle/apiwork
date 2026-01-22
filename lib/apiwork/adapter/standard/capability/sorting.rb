# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Capability
        class Sorting < Adapter::Capability::Base
          capability_name :sorting
          applies_to :index
          input :collection

          option :max_depth, default: 2, type: :integer

          api ApiBuilder
          contract ContractBuilder
          apply_collection CollectionApplier
        end
      end
    end
  end
end
