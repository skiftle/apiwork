# frozen_string_literal: true

module Apiwork
  module Adapter
    module Serializer
      module Error
        class Default < Base
          class APIBuilder < Adapter::Builder::API::Base
            def build
              enum(:error_layer, values: %w[http contract domain])

              object(:error_issue) do |object|
                object.string(:code)
                object.string(:detail)
                object.array(:path) do |array|
                  array.of(:union) do |union|
                    union.variant(&:string)
                    union.variant(&:integer)
                  end
                end
                object.string(:pointer)
                object.object(:meta)
              end

              object(data_type) do |object|
                object.reference(:layer, to: :error_layer)
                object.array(:issues) do |element|
                  element.reference(:error_issue)
                end
              end
            end
          end
        end
      end
    end
  end
end
