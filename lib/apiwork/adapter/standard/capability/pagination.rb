# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Capability
        class Pagination < Adapter::Capability::Base
          capability_name :pagination
          applies_to :index
          input :collection

          option :strategy, default: :offset, enum: %i[offset cursor], type: :symbol
          option :default_size, default: 20, type: :integer
          option :max_size, default: 100, type: :integer

          applier Applier
          api_types_class ApiTypes
          contract_types_class ContractTypes
          response_types_class ResponseTypes
        end
      end
    end
  end
end
