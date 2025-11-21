# frozen_string_literal: true

module Apiwork
  module Contract
    module Schema
      module Extension
        extend ActiveSupport::Concern

        class_methods do
          def auto_generate_and_store_action(action_name)
            action_definition = Generator.generate_action(schema_class, action_name, contract_class: self)
            @action_definitions[action_name.to_sym] = action_definition if action_definition
          end
        end
      end
    end
  end
end
