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
        #     transform { |request| request.transform(&:deep_symbolize_keys) }
        #     transform OpFieldTransformer, stage: :post
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
        #       prepare { |record, schema_class, state| ... }
        #       render { |data, schema_class, state| ... }
        #     end
        #     collection do
        #       prepare { |collection, schema_class, state| ... }
        #       render { |result, schema_class, state| ... }
        #     end
        #     error do
        #       render { |issues, layer, state| ... }
        #     end
        #     transform { |response| response }
        #   end
        def response(&block)
          return @response ||= Hook::Response.new unless block

          @response ||= Hook::Response.new
          @response.instance_eval(&block)
        end

        def inherited(subclass)
          super

          parent_request = @request || Hook::Request.new
          parent_response = @response || Hook::Response.new

          subclass_request = Hook::Request.new
          subclass_request.inherit_from(parent_request)

          subclass_response = Hook::Response.new
          subclass_response.inherit_from(parent_response)

          subclass.instance_variable_set(:@register, Hook::Register.new)
          subclass.instance_variable_set(:@request, subclass_request)
          subclass.instance_variable_set(:@response, subclass_response)
        end
      end

      request do
        transform KeyNormalizer
      end

      response do
        transform KeyTransformer
      end

      def register_api(registrar, capabilities)
        self.class.register.run_api(registrar, capabilities)
      end

      def register_contract(registrar, schema_class, actions)
        self.class.register.run_contract(registrar, schema_class, actions)
      end

      def render_collection(collection, schema_class, state)
        hooks = self.class.response.collection
        prepared = hooks.run_prepare(collection, schema_class, state)
        serialized = serialize_collection(prepared, schema_class, state)
        hooks.run_render(serialized, schema_class, state)
      end

      def render_record(record, schema_class, state)
        hooks = self.class.response.record
        prepared = hooks.run_prepare(record, schema_class, state)
        serialized = serialize_record(prepared, schema_class, state)
        hooks.run_render(serialized, schema_class, state)
      end

      def render_error(layer, issues, state)
        hooks = self.class.response.error
        prepared = hooks.run_prepare(issues, layer, state)
        hooks.run_render(prepared, layer, state)
      end

      def normalize_request(request, api_class:)
        self.class.request.run_transforms(request, api_class:)
      end

      def prepare_request(request, api_class:)
        self.class.request.run_post_transforms(request, api_class:)
      end

      def transform_response(response, api_class:)
        self.class.response.run_transforms(response, api_class:)
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
