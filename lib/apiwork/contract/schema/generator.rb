# frozen_string_literal: true

module Apiwork
  module Contract
    module Schema
      # Main entry point for contract schema generation
      # Delegates to specialized generators for input, output, and type registration
      class Generator
        class << self
          # Generate action definition for a CRUD action
          # Delegates to InputGenerator and OutputGenerator
          def generate_action(schema_class, action, contract_class: nil)
            return nil unless schema_class

            contract_class ||= Class.new(Base) do
              schema schema_class
            end

            TypeRegistry.register_contract_enums(contract_class, schema_class)

            action_definition = Apiwork::Contract::ActionDefinition.new(action, contract_class)

            case action.to_sym
            when :index
              action_definition.input do
                InputGenerator.generate_query_params(self, schema_class)
              end
              action_definition.output do
                OutputGenerator.generate_collection_output(self, schema_class)
              end
            when :show
              action_definition.input do
                # Empty input - strict mode will reject any query params
              end
              action_definition.output do
                OutputGenerator.generate_single_output(self, schema_class)
              end
            when :create
              action_definition.input do
                InputGenerator.generate_writable_input(self, schema_class, :create)
              end
              action_definition.output do
                OutputGenerator.generate_single_output(self, schema_class)
              end
            when :update
              action_definition.input do
                InputGenerator.generate_writable_input(self, schema_class, :update)
              end
              action_definition.output do
                OutputGenerator.generate_single_output(self, schema_class)
              end
            when :destroy
              # Destroy returns empty response (just 200 OK)
              action_definition.output do
                # Empty output
              end
            else
              # Custom member/collection actions (e.g., :search, :publish, :archive)
              # Default to single resource output (unwrapped discriminated union)
              # This works well for member actions that return a single resource
              # Collection actions should define explicit output with reset_output! if they return arrays
              action_definition.output do
                OutputGenerator.generate_single_output(self, schema_class)
              end
            end

            action_definition
          end

          # Map resource type to contract type
          def map_type(resource_type)
            case resource_type
            when :string then :string
            when :integer then :integer
            when :boolean then :boolean
            when :datetime then :datetime
            when :date then :date
            when :uuid then :uuid
            when :decimal, :float then :decimal
            when :object then :object
            when :array then :array
            else :string
            end
          end
        end
      end
    end
  end
end
