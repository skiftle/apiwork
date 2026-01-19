# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Feature
        class Filtering < Adapter::Feature
          feature_name :filtering

          option :max_depth, default: 3, type: :integer

          def apply(data, state)
            return data unless state.action.index?
            return data unless state.schema_class
            return data unless data.is_a?(Hash) && data.key?(:data)

            collection = data[:data]
            return data unless collection.is_a?(ActiveRecord::Relation)

            filter_params = state.request&.query&.dig(:filter)
            return data if filter_params.blank?

            issues = []
            filtered = CollectionLoader::Filter.filter(collection, state.schema_class, filter_params, issues)

            raise ContractError, issues if issues.any?

            data.merge(data: filtered)
          end
        end
      end
    end
  end
end
