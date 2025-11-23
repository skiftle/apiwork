# frozen_string_literal: true

module Apiwork
  module Contract
    module Schema
      class Generator
        class << self
          def generate_action(schema_class, action, contract_class:)
            return nil unless schema_class
            raise ArgumentError, 'contract_class is required' unless contract_class

            TypeBuilder.build_contract_enums(contract_class, schema_class)

            action_definition = Apiwork::Contract::ActionDefinition.new(action_name: action, contract_class: contract_class)

            case action.to_sym
            when :index
              action_definition.request do
                query { RequestGenerator.generate_query_params(self, schema_class) }
              end
              action_definition.response do
                body { ResponseGenerator.generate_collection_response(self, schema_class) }
              end
            when :show
              action_definition.request do
              end
              action_definition.response do
                body { ResponseGenerator.generate_single_response(self, schema_class) }
              end
            when :create
              action_definition.request do
                body { RequestGenerator.generate_writable_request(self, schema_class, :create) }
              end
              action_definition.response do
                body { ResponseGenerator.generate_single_response(self, schema_class) }
              end
            when :update
              action_definition.request do
                body { RequestGenerator.generate_writable_request(self, schema_class, :update) }
              end
              action_definition.response do
                body { ResponseGenerator.generate_single_response(self, schema_class) }
              end
            when :destroy
              action_definition.response do
              end
            else
              action_definition.response do
              end
            end

            action_definition
          end

          def map_type(type)
            case type
            when :string, :text then :string
            when :integer then :integer
            when :boolean then :boolean
            when :datetime then :datetime
            when :date then :date
            when :time then :time
            when :uuid then :uuid
            when :decimal, :float then :decimal
            when :object then :object
            when :array then :array
            when :json, :jsonb then :object
            when :unknown then :unknown
            else :unknown
            end
          end
        end
      end
    end
  end
end
