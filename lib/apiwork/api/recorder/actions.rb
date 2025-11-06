# frozen_string_literal: true

module Apiwork
  module API
    class Recorder
      # Handles recording of member/collection actions
      module Actions
        # Member block context
        def member(&block)
          @in_member_block = true
          instance_eval(&block)
          @in_member_block = false
        end

        # Collection block context
        def collection(&block)
          @in_collection_block = true
          instance_eval(&block)
          @in_collection_block = false
        end

        # HTTP verbs - capture method and action(s)
        # Supports both single action and array of actions:
        #   patch :archive, on: :member
        #   patch %i[archive unarchive], on: :member
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

        # Handle both single action and array of actions
        def capture_actions(actions, method:, options:)
          # Convert to array if single action provided
          actions_array = Array(actions)

          # Capture each action separately
          actions_array.each do |action|
            capture_action(action, method: method, options: options)
          end
        end

        def capture_action(action, method:, options:)
          current_resource = @resource_stack.last
          return unless current_resource

          # Validate :on parameter if provided
          if options[:on] && ![:member, :collection].include?(options[:on])
            raise Apiwork::ConfigurationError,
                  ":on option must be either :member or :collection, got #{options[:on].inspect}"
          end

          # Extract contract path (Rails-style)
          contract_path = options[:contract]

          # Resolve contract path to full class name if provided
          contract_class_name = contract_path ? resolve_contract_path(contract_path) : nil

          if @in_member_block || options[:on] == :member
            # Member action - add to members hash
            @metadata.add_member_action(
              current_resource,
              action,
              method: method,
              options: options,
              contract_class_name: contract_class_name
            )
          elsif @in_collection_block || options[:on] == :collection
            # Collection action - add to collections hash
            @metadata.add_collection_action(
              current_resource,
              action,
              method: method,
              options: options,
              contract_class_name: contract_class_name
            )
          else
            # Action declared without member/collection context - this is an error
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
