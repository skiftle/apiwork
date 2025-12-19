# frozen_string_literal: true

module Apiwork
  module API
    class Recorder
      # @api private
      module Action
        # Defines member actions (operate on a specific resource).
        #
        # Member actions include :id in the URL path.
        # Use inside a resources block.
        #
        # @yield block containing HTTP method declarations
        #
        # @example
        #   resources :invoices do
        #     member do
        #       post :archive
        #       post :send_reminder
        #     end
        #   end
        #   # Routes: POST /invoices/:id/archive, POST /invoices/:id/send_reminder
        def member(&block)
          @in_member_block = true
          instance_eval(&block)
          @in_member_block = false
        end

        # Defines collection actions (operate on the resource collection).
        #
        # Collection actions don't include :id in the URL path.
        # Use inside a resources block.
        #
        # @yield block containing HTTP method declarations
        #
        # @example
        #   resources :invoices do
        #     collection do
        #       get :search
        #       post :bulk_create
        #     end
        #   end
        #   # Routes: GET /invoices/search, POST /invoices/bulk_create
        def collection(&block)
          @in_collection_block = true
          instance_eval(&block)
          @in_collection_block = false
        end

        # Declares a PATCH action.
        #
        # @param actions [Symbol, Array<Symbol>] action name(s)
        # @param options [Hash] action options
        # @option options [Symbol] :on :member or :collection (required outside block)
        # @option options [String] :contract custom contract path
        #
        # @example
        #   member { patch :partial_update }
        def patch(actions, **options)
          capture_actions(actions, method: :patch, options: options)
        end

        # Declares a GET action.
        #
        # @param actions [Symbol, Array<Symbol>] action name(s)
        # @param options [Hash] action options
        # @option options [Symbol] :on :member or :collection (required outside block)
        # @option options [String] :contract custom contract path
        #
        # @example Inside member block
        #   member { get :status }
        #
        # @example With :on option
        #   get :status, on: :member
        def get(actions, **options)
          capture_actions(actions, method: :get, options: options)
        end

        # Declares a POST action.
        #
        # @param actions [Symbol, Array<Symbol>] action name(s)
        # @param options [Hash] action options
        # @option options [Symbol] :on :member or :collection (required outside block)
        # @option options [String] :contract custom contract path
        #
        # @example
        #   member { post :archive }
        #   collection { post :bulk_create }
        def post(actions, **options)
          capture_actions(actions, method: :post, options: options)
        end

        # Declares a PUT action.
        #
        # @param actions [Symbol, Array<Symbol>] action name(s)
        # @param options [Hash] action options
        # @option options [Symbol] :on :member or :collection (required outside block)
        # @option options [String] :contract custom contract path
        #
        # @example
        #   member { put :replace }
        def put(actions, **options)
          capture_actions(actions, method: :put, options: options)
        end

        # Declares a DELETE action.
        #
        # @param actions [Symbol, Array<Symbol>] action name(s)
        # @param options [Hash] action options
        # @option options [Symbol] :on :member or :collection (required outside block)
        # @option options [String] :contract custom contract path
        #
        # @example
        #   member { delete :remove_attachment }
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
