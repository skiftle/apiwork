# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Capability
        class Sorting
          class ContractBuilder < Adapter::Capability::ContractBuilder::Base
            def build
              TypeBuilder.build(registrar, schema_class)

              return unless type?(:sort)

              action(:index) do
                request do
                  query do
                    union? :sort do
                      variant { reference :sort }
                      variant { array { reference :sort } }
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
