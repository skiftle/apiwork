# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Feature
        class Sorting < Adapter::Feature
          feature_name :sorting

          option :max_depth, default: 2, type: :integer

          def apply(data, state)
            return data unless state.action.index?
            return data unless state.schema_class
            return data unless data.is_a?(Hash) && data.key?(:data)

            collection = data[:data]
            return data unless collection.is_a?(ActiveRecord::Relation)

            sort_params = state.request&.query&.dig(:sort)

            issues = []
            sorted = Sorter.sort(collection, state.schema_class, sort_params, issues)

            raise ContractError, issues if issues.any?

            data.merge(data: sorted)
          end
        end
      end
    end
  end
end
