# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Feature
        class Preloading < Adapter::Feature
          feature_name :preloading

          def apply(data, state)
            return data unless state.action.index?
            return data unless state.schema_class
            return data unless data.is_a?(Hash) && data.key?(:data)

            collection = data[:data]
            return data unless collection.is_a?(ActiveRecord::Relation)

            params = state.request&.query&.slice(:filter, :include, :page, :sort) || {}
            loaded = EagerLoader.load(collection, state.schema_class, params)

            data.merge(data: loaded)
          end
        end
      end
    end
  end
end
