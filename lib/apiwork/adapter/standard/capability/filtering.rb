# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Capability
        class Filtering < Adapter::Capability::Base
          capability_name :filtering
          applies_to :index
          input :collection

          option :max_depth, default: 3, type: :integer

          applier Applier
          api_types_class ApiTypes
          contract_types_class ContractTypes
        end
      end
    end
  end
end
