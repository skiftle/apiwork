# frozen_string_literal: true

module Apiwork
  module API
    # Routing DSL for API classes
    #
    # Provides: resources, resource, concern, with_options
    #
    # Uses Rails-style convention-based resolution for contracts and controllers.
    # Resources are always auto-detected from namespace and resource name.
    #
    module Routing
      # Define RESTful resources
      #
      # @param name [Symbol] Resource name (e.g., :posts)
      # @param options [Hash] Resource options
      # @option options [String] :contract Rails-style contract path (e.g., 'admin/post' or '/custom/post')
      # @option options [String] :controller Rails-style controller path (e.g., 'admin/posts')
      # @option options [Array<Symbol>] :only Restrict to specific actions
      # @option options [Array<Symbol>] :except Exclude specific actions
      # @option options [Array<Symbol>] :concerns Apply concerns
      # @yield Block for nested resources
      #
      # @example Basic usage (uses conventions)
      #   resources :posts
      #   # → Schema: Api::V1::PostSchema
      #   # → Contract: Api::V1::PostContract
      #   # → Controller: Api::V1::PostsController
      #
      # @example With contract override (relative path)
      #   resources :posts, contract: 'admin/post'
      #   # → Contract: Api::V1::Admin::PostContract
      #
      # @example With absolute contract path
      #   resources :posts, contract: '/custom/post'
      #   # → Contract: Custom::PostContract
      #
      # @example With both overrides
      #   resources :posts, contract: 'admin/post', controller: 'admin/posts'
      #
      # @example With nested resources
      #   resources :accounts do
      #     resources :clients
      #   end
      #
      def resources(name, **options, &block)
        @recorder.resources(name, **options, &block)
      end

      # Define singular resource
      #
      # @param name [Symbol] Resource name (e.g., :user)
      # @param options [Hash] Resource options (same as resources)
      # @yield Block for nested resources
      #
      # @example
      #   resource :user, only: %i[show update destroy]
      #
      def resource(name, **options, &block)
        @recorder.resource(name, **options, &block)
      end

      # Define reusable concern
      #
      # @param name [Symbol] Concern name
      # @yield Block with concern definition
      # @example
      #   concern :auditable do
      #     resources :audit_logs, only: %i[index show]
      #   end
      def concern(name, &block)
        @recorder.concern(name, &block)
      end

      # Apply options to multiple resources
      #
      # @param options [Hash] Options to apply
      # @yield Block with resources
      # @example
      #   with_options param: :code, only: %i[index show] do
      #     resources :countries
      #     resources :currencies
      #   end
      def with_options(options = {}, &block)
        @recorder.with_options(options, &block)
      end
    end
  end
end
