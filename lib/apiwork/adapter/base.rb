# frozen_string_literal: true

module Apiwork
  module Adapter
    # @api public
    # Base class for adapters.
    #
    # Subclass this to create custom response formats (JSON:API, HAL, etc.).
    # Use the hooks DSL to define request/response transformations.
    #
    # @example Custom adapter with hooks
    #   class JSONAPIAdapter < Apiwork::Adapter::Base
    #     adapter_name :jsonapi
    #
    #     response do
    #       record do
    #         render { |data, schema_class, state|
    #           { data: { type: schema_class.root_key.singular, attributes: data } }
    #         }
    #       end
    #     end
    #   end
    #
    #   # Register the adapter
    #   Apiwork::Adapter.register(JSONAPIAdapter)
    class Base
      include Configurable

      class << self
        # @api public
        # The adapter name.
        #
        # @param value [Symbol, nil] the adapter name to set
        # @return [Symbol, nil]
        def adapter_name(value = nil)
          @adapter_name = value.to_sym if value
          @adapter_name
        end

        # @api public
        # Defines registration hooks for API and contract setup.
        #
        # @yield block evaluated in the context of {Hook::Register}
        # @see Hook::Register
        #
        # @example
        #   register do
        #     api { |registrar, capabilities| ... }
        #     contract { |registrar, schema_class, actions| ... }
        #   end
        def register(&block)
          return @register ||= Hook::Register.new unless block

          @register ||= Hook::Register.new
          @register.instance_eval(&block)
        end

        # @api public
        # Defines request transformation hooks.
        #
        # @yield block evaluated in the context of {Hook::Request}
        # @see Hook::Request
        #
        # @example
        #   request do
        #     before_validation { |request| request.transform(&:deep_symbolize_keys) }
        #     after_validation { |request| request }
        #   end
        def request(&block)
          return @request ||= Hook::Request.new unless block

          @request ||= Hook::Request.new
          @request.instance_eval(&block)
        end

        # @api public
        # Defines response transformation hooks.
        #
        # @yield block evaluated in the context of {Hook::Response}
        # @see Hook::Response
        #
        # @example
        #   response do
        #     record do
        #       prepare { |record, state| ... }
        #       render { |data, state| ... }
        #     end
        #     collection do
        #       prepare { |collection, state| ... }
        #       render { |result, state| ... }
        #     end
        #     error do
        #       prepare { |issues, state| ... }
        #       render { |issues, state| ... }
        #     end
        #     finalize { |response| response }
        #   end
        def response(&block)
          return @response ||= Hook::Response.new unless block

          @response ||= Hook::Response.new
          @response.instance_eval(&block)
        end

        def inherited(subclass)
          super
          subclass.instance_variable_set(:@register, Hook::Register.new)
          subclass.instance_variable_set(:@request, Hook::Request.new)
          subclass.instance_variable_set(:@response, Hook::Response.new)
        end
      end

      # @api public
      # Registers types from schemas for the API.
      # Uses the api hook defined in the register block.
      # @see Adapter::APIRegistrar
      # @see Adapter::Capabilities
      def register_api(registrar, capabilities)
        self.class.register.run_api(registrar, capabilities)
      end

      # @api public
      # Registers types for a contract.
      #
      # Called once per contract during API initialization. Uses the contract
      # hook defined in the register block.
      #
      # @param registrar [Adapter::ContractRegistrar] for defining contract-scoped types
      # @param schema_class [Class] a {Schema::Base} subclass with attribute/association metadata
      # @param actions [Hash{Symbol => Adapter::Action}] resource actions.
      #   Keys are action names (:index, :show, :create, :update, :destroy, or custom)
      #
      # @see Adapter::ContractRegistrar
      # @see Schema::Base
      # @see Adapter::Action
      def register_contract(registrar, schema_class, actions)
        self.class.register.run_contract(registrar, schema_class, actions)
      end

      # @api public
      # Renders a collection response.
      #
      # Flow: prepare → serialize → render.
      #
      # @param collection [Enumerable] the records to render
      # @param schema_class [Class] a {Schema::Base} subclass
      # @param state [Adapter::RenderState] runtime context
      # @return [Hash] the response hash
      # @see Adapter::RenderState
      def render_collection(collection, schema_class, state)
        hooks = self.class.response.collection
        prepared = hooks.run_prepare(collection, schema_class, state)
        serialized = serialize_collection(prepared, schema_class, state)
        hooks.run_render(serialized, schema_class, state)
      end

      # @api public
      # Renders a single record response.
      #
      # Flow: prepare → serialize → render.
      #
      # @param record [Object] the record to render
      # @param schema_class [Class] a {Schema::Base} subclass
      # @param state [Adapter::RenderState] runtime context
      # @return [Hash] the response hash
      # @see Adapter::RenderState
      def render_record(record, schema_class, state)
        hooks = self.class.response.record
        prepared = hooks.run_prepare(record, schema_class, state)
        serialized = serialize_record(prepared, schema_class, state)
        hooks.run_render(serialized, schema_class, state)
      end

      # @api public
      # Renders an error response.
      #
      # Flow: prepare → render.
      #
      # @param layer [Symbol] the error layer (:http, :contract, :domain)
      # @param issues [Array<Issue>] the validation issues
      # @param state [Adapter::RenderState] runtime context
      # @return [Hash] the error response hash
      # @see Issue
      def render_error(layer, issues, state)
        hooks = self.class.response.error
        prepared = hooks.run_prepare(issues, layer, state)
        hooks.run_render(prepared, layer, state)
      end

      # @api public
      # Normalizes incoming request parameters before validation.
      # Uses the before_validation hook from the request block.
      #
      # @param request [Request] the request to normalize
      # @return [Request] the normalized request
      # @see Request
      def normalize_request(request)
        self.class.request.run_before_validation(request)
      end

      # @api public
      # Prepares validated parameters before the controller receives them.
      # Uses the after_validation hook from the request block.
      #
      # @param request [Request] the validated request
      # @return [Request] the prepared request
      # @see Request
      def prepare_request(request)
        self.class.request.run_after_validation(request)
      end

      # @api public
      # Transforms outgoing response data.
      # Uses the finalize hook from the response block.
      #
      # @param response [Response] the response to transform
      # @return [Response] the transformed response
      # @see Response
      def transform_response(response)
        self.class.response.run_finalize(response)
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

      private

      def serialize_collection(prepared, schema_class, state)
        return prepared unless schema_class
        return prepared unless prepared.is_a?(Hash) && prepared.key?(:data)

        data = prepared[:data]
        include_param = state.request&.query&.dig(:include)
        serialized = schema_class.serialize(data, context: state.context, include: include_param)

        prepared.merge(data: serialized)
      end

      def serialize_record(prepared, schema_class, state)
        return prepared unless schema_class

        include_param = state.request&.query&.dig(:include)
        schema_class.serialize(prepared, context: state.context, include: include_param)
      end
    end
  end
end
