# frozen_string_literal: true

module Apiwork
  module Adapter
    module Serialization
      class Default < Base
        module Types
          class Errors
            class << self
              def build(registrar, capabilities)
                new(registrar).build
              end
            end

            def initialize(registrar)
              @registrar = registrar
            end

            def build
              @registrar.enum :layer, values: %w[http contract domain]

              @registrar.object :issue do
                string :code
                string :detail
                array :path do
                  string
                end
                string :pointer
                object :meta
              end

              @registrar.object :error_response_body do
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
