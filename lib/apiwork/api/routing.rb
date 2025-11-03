# frozen_string_literal: true

module Apiwork
  module API
    # Routing DSL for API classes
    #
    # Provides: resources, resource, concern, with_options
    module Routing
      # Define RESTful resources
      #
      # @param name [Symbol] Resource name
      # @param options [Hash] Resource options (only, except, concerns, etc.)
      # @yield Block for nested resources
      # @example
      #   resources :accounts do
      #     resources :clients
      #   end
      def resources(name, **options, &block)
        @recorder.resources(name, **options, &block)
      end

      # Define singular resource
      #
      # @param name [Symbol] Resource name
      # @param options [Hash] Resource options
      # @yield Block for nested resources
      # @example
      #   resource :user, only: %i[show update destroy]
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
