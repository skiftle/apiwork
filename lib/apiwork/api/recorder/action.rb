# frozen_string_literal: true

module Apiwork
  module API
    class Recorder
      module Action
        def member(&block)
          @in_member_block = true
          instance_eval(&block)
          @in_member_block = false
        end

        def collection(&block)
          @in_collection_block = true
          instance_eval(&block)
          @in_collection_block = false
        end

        def patch(actions, **options)
          capture_actions(actions, method: :patch, options: options)
        end

        def get(actions, **options)
          capture_actions(actions, method: :get, options: options)
        end

        def post(actions, **options)
          capture_actions(actions, method: :post, options: options)
        end

        def put(actions, **options)
          capture_actions(actions, method: :put, options: options)
        end

        def delete(actions, **options)
          capture_actions(actions, method: :delete, options: options)
        end

        private

        def capture_actions(actions, method:, options:)
          actions_array = Array(actions)

          actions_array.each do |action|
            capture_action(action, method: method, options: options)
          end
        end

        def capture_action(action, method:, options:)
          current_resource = @resource_stack.last
          return unless current_resource

          if options[:on] && [:member, :collection].exclude?(options[:on])
            raise Apiwork::ConfigurationError,
                  ":on option must be either :member or :collection, got #{options[:on].inspect}"
          end

          contract_path = options[:contract]
          contract_class = contract_path ? contract_path_to_class_name(contract_path) : nil

          action_type = if @in_member_block || options[:on] == :member
                          :member
                        elsif @in_collection_block || options[:on] == :collection
                          :collection
                        end

          if action_type
            @metadata.add_action(
              current_resource,
              action,
              type: action_type,
              method: method,
              options: options,
              contract_class: contract_class
            )
          else
            raise Apiwork::ConfigurationError,
                  "Action '#{action}' on resource '#{current_resource}' must be declared " \
                  "within a member or collection block, or use the :on parameter.\n" \
                  "Examples:\n" \
                  "  member { #{method} :#{action} }\n" \
                  "  #{method} :#{action}, on: :member\n" \
                  "  collection { #{method} :#{action} }\n" \
                  "  #{method} :#{action}, on: :collection"
          end
        end
      end
    end
  end
end
