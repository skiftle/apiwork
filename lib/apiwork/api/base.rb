# frozen_string_literal: true

module Apiwork
  module API
    # Base class for API definitions
    #
    # Define APIs using a declarative DSL:
    #
    # @example Basic API
    #   class V1API < Apiwork::API
    #     namespaces :api, :v1
    #     schema :openapi
    #     schema :transport
    #     schema :zod
    #
    #     resources :accounts do
    #       resources :clients
    #     end
    #   end
    #
    # @example API with documentation
    #   class V1API < Apiwork::API
    #     namespaces :api, :v1
    #     schema :openapi
    #     schema :transport
    #
    #     doc do
    #       title "My API"
    #       version "1.0.0"
    #     end
    #
    #     resources :accounts, concerns: [:auditable]
    #   end
    class Base
      extend Configuration   # Adds: configure_from_path, mount_at, schema
      extend Documentation   # Adds: doc
      extend Routing         # Adds: resources, resource, concern, with_options

      class << self
        attr_reader :metadata, :recorder, :mount_path, :namespaces_parts, :schemas

        # Get controller namespace derived from namespaces parts
        #
        # @return [String] Controller namespace (e.g., "Api::V1")
        def controller_namespace
          namespaces_parts.map(&:to_s).map(&:camelize).join('::')
        end
      end
    end
  end
end
