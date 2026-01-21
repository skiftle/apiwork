# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Capability
        class Filtering
          class ContractTypes < Adapter::Capability::ContractTypes::Base
            def register(context)
              TypeBuilder.build(context.registrar, context.schema_class)

              return unless context.registrar.type?(:filter)

              context.registrar.action(:index) do
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
