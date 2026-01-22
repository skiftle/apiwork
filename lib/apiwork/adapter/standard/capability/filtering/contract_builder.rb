# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Capability
        class Filtering
          class ContractBuilder < Adapter::Capability::ContractBuilder::Base
            def build
              TypeBuilder.build(registrar, schema_class)

              return unless type?(:filter)

              action(:index) do
                request do
                  query do
                    union? :filter do
                      variant { reference :filter }
                      variant { array { reference :filter } }
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
