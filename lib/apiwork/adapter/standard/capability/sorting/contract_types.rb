# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Capability
        class Sorting
          class ContractTypes < Adapter::Capability::ContractTypes::Base
            def register(context)
              TypeBuilder.build(context.registrar, context.schema_class)

              return unless context.registrar.type?(:sort)

              context.registrar.action(:index) do
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
