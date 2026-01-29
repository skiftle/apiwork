# frozen_string_literal: true

module Apiwork
  module Adapter
    module Serializer
      module Error
        class Default < Base
          class APIBuilder < Adapter::Builder::API::Base
            def build
              enum(:layer, values: %w[http contract domain])

              object(:issue) do |object|
                object.string(:code)
                object.string(:detail)
                object.array(:path, &:string)
                object.string(:pointer)
                object.object(:meta)
              end

              object(:error_response_body) do |object|
                object.reference(:layer)
                object.array(:issues) do |element|
                  element.reference(:issue)
                end
              end
            end
          end
        end
      end
    end
  end
end
