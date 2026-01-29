# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Capability
        class Sorting
          class Builder
            class API < Adapter::Capability::API::Base
              def build
                return unless features.sortable?

                enum :sort_direction, values: %w[asc desc]
              end
            end
          end
        end
      end
    end
  end
end
