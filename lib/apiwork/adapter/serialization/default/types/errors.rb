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

              @api_class.object :issue do
                string :code
                string :detail
                array :path do
                  string
                end
                string :pointer
                object :meta
              end

              @api_class.object :error_response_body do
                reference :layer
                array :issues do
                  reference :issue
                end
              end
            end
          end
        end
      end
    end
  end
end
