# frozen_string_literal: true

module Apiwork
  module Contract
    module Schema
      module Extension
        extend ActiveSupport::Concern

        class_methods do
          def auto_generate_and_store_action(action_name)
            action_definition = Generator.generate_action(schema_class, action_name, contract_class: self)
            return unless action_definition

            action_definitions[action_name.to_sym] = action_definition

            schema_data = Adapter::SchemaData.new(schema_class)
            api_class.adapter.build_action(action_definition, action_name, schema_data)
          end
        end
      end
    end
  end
end
