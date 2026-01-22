# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Capability
        class Sorting
          class ApiBuilder < Adapter::Capability::ApiBuilder::Base
            def build
              return unless capabilities.sortable?

              enum :sort_direction, values: %w[asc desc]
            end
          end
        end
      end
    end
  end
end
