# frozen_string_literal: true

module Apiwork
  module Adapter
    # @api public
    # Base class for adapters.
    #
    # Subclass this to create custom response formats (JSON:API, HAL, etc.).
    # Override the render and transform methods to customize behavior.
    #
    # @example Custom adapter
    #   class JSONAPIAdapter < Apiwork::Adapter::Base
    #     adapter_name :jsonapi
    #
    #     def render_record(record, schema_class, state)
    #       { data: { type: '...', attributes: '...' } }
    #     end
    #   end
    #
    #   # Register the adapter
    #   Apiwork::Adapter.register(JSONAPIAdapter)
    class Base
      include Configurable

      class << self
        # @api public
        # Sets or returns the adapter name identifier.
        #
        # @param name [Symbol, nil] the adapter name to set
        # @return [Symbol, nil] the adapter name, or nil if not set
        def adapter_name(name = nil)
          @adapter_name = name.to_sym if name
          @adapter_name
        end
      end

      # @api public
      # Registers types from schemas for the API.
      # Override to customize type registration.
      # @see Adapter::APIRegistrar
      # @see Adapter::Capabilities
      def register_api(registrar, capabilities)
        raise NotImplementedError
      end

      # @api public
      # Registers types for a contract.
      #
      # Called once per contract during API initialization. Override to customize
      # how request/response types are generated from schema definitions.
      #
      # @param registrar [Adapter::ContractRegistrar] for defining contract-scoped types
      # @param schema_class [Class] a {Schema::Base} subclass with attribute/association metadata
      # @param actions [Hash{Symbol => Adapter::Action}] resource actions.
      #   Keys are action names (:index, :show, :create, :update, :destroy, or custom)
      #
      # @see Adapter::ContractRegistrar
      # @see Schema::Base
      # @see Adapter::Action
      #
      # @example
      #   def register_contract(registrar, schema_class, actions)
      #     actions.each do |name, action|
      #       definition = registrar.action(name)
      #
      #       if action.collection?
      #         definition.request do
      #           query do
      #             param :page, type: :integer, optional: true
      #           end
      #         end
      #       end
      #     end
      #   end
      def register_contract(registrar, schema_class, actions)
        raise NotImplementedError
      end

      # @api public
      # Renders a collection response.
      #
      # @param collection [Enumerable] the records to render
      # @param schema_class [Class] a {Schema::Base} subclass
      # @param state [Adapter::RenderState] runtime context
      # @return [Hash] the response hash
      # @see Adapter::RenderState
      def render_collection(collection, schema_class, state)
        raise NotImplementedError
      end

      # @api public
      # Renders a single record response.
      #
      # @param record [Object] the record to render
      # @param schema_class [Class] a {Schema::Base} subclass
      # @param state [Adapter::RenderState] runtime context
      # @return [Hash] the response hash
      # @see Adapter::RenderState
      def render_record(record, schema_class, state)
        raise NotImplementedError
      end

      # @api public
      # Renders an error response.
      #
      # @param layer [Symbol] the error layer (:http, :contract, :domain)
      # @param issues [Array<Issue>] the validation issues
      # @param state [Adapter::RenderState] runtime context
      # @return [Hash] the error response hash
      # @see Issue
      def render_error(layer, issues, state)
        raise NotImplementedError
      end

      # @api public
      # Transforms incoming request parameters.
      # Override to customize key casing, unwrapping, etc.
      #
      # @param hash [Hash] the request parameters
      # @param schema_class [Class] a {Schema::Base} subclass (optional)
      # @return [Hash] the transformed parameters
      def transform_request(hash, schema_class)
        hash
      end

      # @api public
      # Transforms outgoing response data.
      # Override to customize key casing, wrapping, etc.
      #
      # @param hash [Hash] the response data
      # @param schema_class [Class] a {Schema::Base} subclass (optional)
      # @return [Hash] the transformed response
      def transform_response(hash, schema_class)
        hash
      end

      def build_api_registrar(api_class)
        APIRegistrar.new(api_class)
      end

      def build_contract_registrar(contract_class)
        ContractRegistrar.new(contract_class)
      end

      def build_capabilities(structure)
        Capabilities.new(structure)
      end
    end
  end
end
