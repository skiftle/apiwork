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
          Array(actions).each do |action|
            capture_action(action, method: method, options: options)
          end
        end

        def capture_action(action, method:, options:)
          resource_name = @resource_stack.last
          return unless resource_name

          resource = @structure.find_resource(resource_name)
          return unless resource

          if options[:on] && [:member, :collection].exclude?(options[:on])
            raise Apiwork::ConfigurationError,
                  ":on option must be either :member or :collection, got #{options[:on].inspect}"
          end

          action_type = if @in_member_block || options[:on] == :member
                          :member
                        elsif @in_collection_block || options[:on] == :collection
                          :collection
                        end

          if action_type
            resource.add_action(action, type: action_type, method: method)
          else
            raise Apiwork::ConfigurationError,
                  "Action '#{action}' on resource '#{resource_name}' must be declared " \
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
