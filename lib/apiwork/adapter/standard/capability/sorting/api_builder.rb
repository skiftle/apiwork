# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Capability
        class Sorting
          class APIBuilder < Adapter::Capability::APIBuilder::Base
            def build
              return unless sortable?

              enum :sort_direction, values: %w[asc desc]
            end
          end
        end
      end
    end
  end
end
