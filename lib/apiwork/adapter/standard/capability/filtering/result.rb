# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Capability
        class Filtering
          class Result < Adapter::Capability::Result::Base
            def apply
              return result(data:) unless data.is_a?(ActiveRecord::Relation)

              filter_params = request.query[:filter]
              return result(data:) if filter_params.blank?

              includes = IncludesResolver::AssociationExtractor.new(schema_class).extract_from_filter(filter_params).keys
              filtered = Filter.apply(data, filter_params, schema_class)

              result(includes:, data: filtered)
            end
          end
        end
      end
    end
  end
end
