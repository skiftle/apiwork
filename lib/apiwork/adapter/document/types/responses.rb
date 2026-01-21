# frozen_string_literal: true

module Apiwork
  module Adapter
    module Document
      module Types
        class Responses
          attr_reader :actions,
                      :capabilities,
                      :registrar,
                      :schema_class

          class << self
            def build(registrar, schema_class, actions, capabilities: [])
              new(registrar, schema_class, actions, capabilities:).build
            end
          end

          def initialize(registrar, schema_class, actions, capabilities: [])
            @registrar = registrar
            @schema_class = schema_class
            @actions = actions
            @capabilities = capabilities
          end

          def build
            build_actions
          end

          def single_response(response)
            response.reference schema_class.root_key.singular.to_sym, to: resource_type_name

            capabilities.each do |capability|
              capability.record_response_types(response, schema_class)
            end

            response.object :meta, optional: true
          end

          def collection_response(response)
            type_name = resource_type_name

            response.array schema_class.root_key.plural.to_sym do
              reference type_name
            end

            capabilities.each do |capability|
              capability.collection_response_types(response, schema_class)
            end

            response.object :meta, optional: true
          end

          private

          def build_actions
            actions.each_value do |action|
              build_action(action)
            end
          end

          def build_action(action)
            contract_action = registrar.action(action.name)

            build_response_for_action(action, contract_action) unless contract_action.resets_response?
          end

          def build_response_for_action(action, contract_action)
            case action.name
            when :index
              result_wrapper = build_result_wrapper(action.name, response_type: :collection)
              build_collection_response(contract_action, result_wrapper)
            when :show, :create, :update
              result_wrapper = build_result_wrapper(action.name, response_type: :single)
              build_single_response(contract_action, result_wrapper)
            when :destroy
              contract_action.response { no_content! }
            else
              if action.method == :delete
                contract_action.response { no_content! }
              elsif action.collection?
                result_wrapper = build_result_wrapper(action.name, response_type: :collection)
                build_collection_response(contract_action, result_wrapper)
              elsif action.member?
                result_wrapper = build_result_wrapper(action.name, response_type: :single)
                build_single_response(contract_action, result_wrapper)
              end
            end
          end

          def build_result_wrapper(action_name, response_type:)
            success_type_name = :"#{action_name}_success_response_body"

            unless registrar.type?(success_type_name)
              builder = self
              registrar.object(success_type_name) do
                if response_type == :collection
                  builder.collection_response(self)
                else
                  builder.single_response(self)
                end
              end
            end

            { error_type: :error_response_body, success_type: registrar.scoped_type_name(success_type_name) }
          end

          def build_single_response(contract_action, result_wrapper)
            builder = self
            contract_action.response do
              self.result_wrapper = result_wrapper
              body { builder.single_response(self) }
            end
          end

          def build_collection_response(contract_action, result_wrapper)
            builder = self
            contract_action.response do
              self.result_wrapper = result_wrapper
              body { builder.collection_response(self) }
            end
          end

          def resource_type_name
            schema_class.root_key.singular.to_sym
          end
        end
      end
    end
  end
end
