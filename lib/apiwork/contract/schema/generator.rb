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

            # Derive API class from schema namespace for anonymous contracts
            api_class_for_schema = derive_api_class_from_schema(schema_class)

            contract_class ||= Class.new(Base) do
              schema schema_class

              # Override api_class for anonymous contracts to use schema's namespace
              define_singleton_method(:api_class) { api_class_for_schema }
            end

            TypeRegistry.register_contract_enums(contract_class, schema_class)

            action_definition = Apiwork::Contract::ActionDefinition.new(action_name: action, contract_class: contract_class)

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
                # Empty
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
              action_definition.output do
                # Empty
              end
            else
              # Custom actions get empty output by default
              # Must define explicit output if needed
              action_definition.output do
                # Empty
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

          private

          # Derive API class from schema class namespace
          # Example: Api::V1::AccountSchema → /api/v1 → finds API class
          def derive_api_class_from_schema(schema_class)
            return nil unless schema_class.name

            namespace_parts = schema_class.name.deconstantize.split('::')
            return nil if namespace_parts.empty?

            api_path = "/#{namespace_parts.map(&:underscore).join('/')}"
            Apiwork::API.find(api_path)
          end
        end
      end
    end
  end
end
