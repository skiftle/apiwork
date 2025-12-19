# frozen_string_literal: true

module Apiwork
  module API
    class Recorder
      module Resource
        # Defines a RESTful resource with standard CRUD actions.
        #
        # Creates routes for index, show, create, update, destroy actions.
        # Nested resources and custom actions can be defined in the block.
        #
        # @param name [Symbol] resource name (plural)
        # @param options [Hash] resource options
        # @option options [Array<Symbol>] :only limit CRUD actions
        # @option options [Array<Symbol>] :except exclude CRUD actions
        # @option options [String] :contract custom contract path
        # @option options [String] :controller custom controller path
        # @option options [Array<Symbol>] :concerns concerns to include
        # @yield block for nested resources and custom actions
        #
        # @example Basic resource
        #   resources :invoices
        #
        # @example Limited actions
        #   resources :invoices, only: [:index, :show]
        #
        # @example With custom actions
        #   resources :invoices do
        #     member { post :archive }
        #     resources :line_items
        #   end
        def resources(name, **options, &block)
          concern_names = options.delete(:concerns)

          capture_resource_metadata(
            name,
            singular: false,
            options: options
          )

          @pending_metadata = {}
          @resource_stack.push(name)

          concerns(*concern_names) if concern_names
          instance_eval(&block) if block

          @resource_stack.pop

          apply_resource_metadata(name)

          apply_crud_action_metadata(name)
        end

        # Defines a singular resource (no index action, no :id in URL).
        #
        # Useful for resources where there's only one instance,
        # like user profile or application settings.
        #
        # @param name [Symbol] resource name (singular)
        # @param options [Hash] resource options (same as resources)
        # @yield block for nested resources and custom actions
        #
        # @example Singular resource
        #   resource :profile
        #   # Routes: GET /profile, PATCH /profile (no index, no :id)
        #
        # @example With actions
        #   resource :settings do
        #     member { post :reset }
        #   end
        def resource(name, **options, &block)
          concern_names = options.delete(:concerns)

          capture_resource_metadata(
            name,
            singular: true,
            options: options
          )

          @pending_metadata = {}
          @resource_stack.push(name)

          concerns(*concern_names) if concern_names
          instance_eval(&block) if block

          @resource_stack.pop

          apply_resource_metadata(name)

          apply_crud_action_metadata(name)
        end

        def with_options(options = {}, &block)
          old_options = @current_options
          @current_options = merged_options(options)

          instance_eval(&block)

          @current_options = old_options
        end

        private

        def merged_options(options = {})
          (@current_options || {}).merge(options)
        end

        def apply_resource_metadata(name)
          resource = @metadata.find_resource(name)
          return unless resource

          resource[:metadata] = {
            summary: @pending_metadata[:summary],
            description: @pending_metadata[:description],
            tags: @pending_metadata[:tags]
          }.compact
        end

        def apply_crud_action_metadata(name)
          resource = @metadata.find_resource(name)
          return unless resource

          crud_actions = resource[:only] || []

          crud_actions.each do |action_name|
            @metadata.add_crud_action(
              name,
              action_name,
              method: crud_action_method(action_name)
            )
          end
        end

        def crud_action_method(action_name)
          case action_name.to_sym
          when :index then :get
          when :show then :get
          when :create then :post
          when :update then :patch
          when :destroy then :delete
          else :get
          end
        end

        def capture_resource_metadata(name, singular:, options:)
          merged = merged_options(options)

          parent = @resource_stack.last

          contract_path = merged.delete(:contract)
          controller_option = merged.delete(:controller)

          contract = if contract_path
                       contract_path_to_class_name(contract_path)
                     else
                       infer_contract_class_name(name)
                     end

          @metadata.add_resource(
            name,
            singular: singular,
            contract: contract,
            controller: controller_option,
            parent: parent,
            **merged
          )
        end
      end
    end
  end
end
