# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Capability
        class Including
          class ContractBuilder < Adapter::Capability::ContractBuilder::Base
            def build
              TypeBuilder.build(registrar, schema_class)

              return unless type?(:include)

              actions.each_key do |action_name|
                action(action_name) do
                  request do
                    query do
                      reference? :include
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
