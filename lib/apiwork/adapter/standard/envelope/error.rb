# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Envelope
        class Error < Adapter::Envelope::Error
          def define(registrar)
            registrar.enum :layer, values: %w[http contract domain]

            registrar.object :issue do
              string :code
              string :detail
              array :path do
                string
              end
              string :pointer
              object :meta
            end

            registrar.object :error_response_body do
              reference :layer
              array :issues do
                reference :issue
              end
            end
          end

          def render(issues, layer, state)
            {
              layer:,
              issues: issues.map(&:to_h),
            }
          end
        end
      end
    end
  end
end
