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

          action_metadata = extract_action_metadata(action, current_resource)

          if @in_member_block || options[:on] == :member
            @metadata.add_member_action(
              current_resource,
              action,
              method: method,
              options: options,
              contract_class: contract_class,
              metadata: action_metadata
            )
          elsif @in_collection_block || options[:on] == :collection
            @metadata.add_collection_action(
              current_resource,
              action,
              method: method,
              options: options,
              contract_class: contract_class,
              metadata: action_metadata
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

        def extract_action_metadata(action, resource_name)
          action_meta = @pending_metadata[:actions]&.delete(action) || {}

          action_type = if @in_member_block || @in_collection_block
                          @in_member_block ? :member : :collection
                        else
                          :member # Default assumption
                        end

          action_meta[:summary] ||= default_action_summary(action, action_type, resource_name)
          action_meta
        end

        def default_action_summary(action, type, resource_name)
          resource_singular = resource_name.to_s.singularize
          resource_plural = resource_name.to_s

          case action.to_sym
          when :index then "List #{resource_plural}"
          when :show then "Get #{resource_singular}"
          when :create then "Create #{resource_singular}"
          when :update then "Update #{resource_singular}"
          when :destroy then "Delete #{resource_singular}"
          else
            if type == :member
              "#{action.to_s.titleize} #{resource_singular}"
            else
              "#{action.to_s.titleize} #{resource_plural}"
            end
          end
        end
      end
    end
  end
end
