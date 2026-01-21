# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Capability
        class Sorting
          class ApiTypes < Adapter::Capability::ApiTypes::Base
            def register(context)
              return unless context.capabilities.sortable?

              context.registrar.enum :sort_direction, values: %w[asc desc]
            end
          end
        end
      end
    end
  end
end
