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

          api_builder APIBuilder
          contract_builder ContractBuilder
          collection_applier CollectionApplier

          response_shape do
            pagination_type = options.strategy == :offset ? :offset_pagination : :cursor_pagination
            reference :pagination, to: pagination_type
          end
        end
      end
    end
  end
end
