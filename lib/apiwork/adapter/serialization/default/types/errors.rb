# frozen_string_literal: true

module Apiwork
  module Adapter
    module Serialization
      class Default < Base
        module Types
          class Errors
            class << self
              def build(api_class, features)
                new(api_class).build
              end
            end

            def initialize(api_class)
              @api_class = api_class
            end

            def build
              @api_class.enum :layer, values: %w[http contract domain]

              @api_class.object(:issue) do |object|
                object.string(:code)
                object.string(:detail)
                object.array(:path, &:string)
                object.string(:pointer)
                object.object(:meta)
              end

              @api_class.object(:error_response_body) do |object|
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
