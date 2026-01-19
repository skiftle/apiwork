# frozen_string_literal: true

module Apiwork
  module Adapter
    class Base
      include Configurable

      class << self
        def adapter_name(value = nil)
          @adapter_name = value.to_sym if value
          @adapter_name
        end

        def api_builder(builder_class = nil)
          @api_builder = builder_class if builder_class
          @api_builder
        end

        def contract_builder(builder_class = nil)
          @contract_builder = builder_class if builder_class
          @contract_builder
        end

        def transform_request(*transformers, post: false)
          @request ||= Hook::Request.new
          transformers.each do |transformer|
            @request.add_transform(transformer, post:)
          end
        end

        def transform_response(*transformers, post: false)
          @response ||= Hook::Response.new
          transformers.each do |transformer|
            @response.add_transform(transformer, post:)
          end
        end

        def request
          @request ||= Hook::Request.new
        end

        def response
          @response ||= Hook::Response.new
        end

        def inherited(subclass)
          super

          parent_request = @request || Hook::Request.new
          parent_response = @response || Hook::Response.new

          subclass_request = Hook::Request.new
          subclass_request.inherit_from(parent_request)

          subclass_response = Hook::Response.new
          subclass_response.inherit_from(parent_response)

          subclass.instance_variable_set(:@request, subclass_request)
          subclass.instance_variable_set(:@response, subclass_response)
        end
      end

      transform_request KeyNormalizer
      transform_response KeyTransformer

      def process_collection(collection, schema_class, state)
        prepared = prepare_collection(collection, schema_class, state)
        serialized = serialize_collection(prepared, schema_class, state)
        render_collection(serialized, schema_class, state)
      end

      def process_record(record, schema_class, state)
        prepared = prepare_record(record, schema_class, state)
        serialized = serialize_record(prepared, schema_class, state)
        render_record(serialized, schema_class, state)
      end

      def process_error(layer, issues, state)
        prepared = prepare_error(issues, layer, state)
        render_error(prepared, layer, state)
      end

      def prepare_record(record, _schema_class, _state)
        record
      end

      def prepare_collection(collection, _schema_class, _state)
        collection
      end

      def prepare_error(issues, _layer, _state)
        issues
      end

      def render_record(data, _schema_class, _state)
        data
      end

      def render_collection(result, _schema_class, _state)
        result
      end

      def render_error(issues, _layer, _state)
        issues
      end

      def register_api(registrar, capabilities)
        builder_class = self.class.api_builder
        return unless builder_class

        builder_class.build(registrar, capabilities)
      end

      def register_contract(registrar, schema_class, actions)
        builder_class = self.class.contract_builder
        return unless builder_class

        builder_class.build(registrar, schema_class, actions)
      end

      def normalize_request(request, api_class:)
        self.class.request.run_before_transforms(request, api_class:)
      end

      def prepare_request(request, api_class:)
        self.class.request.run_after_transforms(request, api_class:)
      end

      def transform_response_output(response, api_class:)
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
