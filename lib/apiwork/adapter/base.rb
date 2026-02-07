# frozen_string_literal: true

module Apiwork
  module Adapter
    # @api public
    # Base class for adapters.
    #
    # The engine of an API. Handles both introspection (generating types from
    # representations) and runtime (processing requests through capabilities,
    # serializing, and wrapping responses). The class declaration acts as a manifest.
    #
    # @example
    #   class MyAdapter < Apiwork::Adapter::Base
    #     adapter_name :my
    #
    #     resource_serializer Serializer::Resource::Default
    #     error_serializer Serializer::Error::Default
    #
    #     member_wrapper Wrapper::Member::Default
    #     collection_wrapper Wrapper::Collection::Default
    #     error_wrapper Wrapper::Error::Default
    #
    #     capability Capability::Filtering
    #     capability Capability::Pagination
    #   end
    class Base
      include Configurable

      class << self
        # @api public
        # The name for this adapter.
        #
        # @param value [Symbol, String, nil] the adapter name
        # @return [Symbol, nil]
        #
        # @example
        #   adapter_name :my
        def adapter_name(value = nil)
          @adapter_name = value.to_sym if value
          @adapter_name
        end

        # @api public
        # Registers a capability for this adapter.
        #
        # Capabilities are self-contained concerns (pagination, filtering, etc.)
        # that handle both introspection and runtime behavior.
        #
        # @param klass [Class<Capability::Base>] the capability class
        # @return [void]
        #
        # @example
        #   capability Capability::Filtering
        #   capability Capability::Pagination
        def capability(klass)
          @capabilities ||= []
          @capabilities << klass

          return unless klass.options.any?

          name = klass.capability_name
          options[name] = Configuration::Option.new(name, :hash, children: klass.options)
        end

        # @api public
        # Skips an inherited capability by name.
        #
        # @param name [Symbol] the capability_name to skip
        # @return [void]
        #
        # @example
        #   skip_capability :pagination
        def skip_capability(name)
          @skipped_capabilities ||= []
          @skipped_capabilities << name.to_sym
        end

        def capabilities
          inherited = superclass.respond_to?(:capabilities) ? superclass.capabilities : []
          skipped = @skipped_capabilities || []
          all = (inherited + (@capabilities || [])).uniq
          all.reject { |capability| skipped.include?(capability.capability_name) }
        end

        # @api public
        # The resource serializer class.
        #
        # Handles serialization of records and collections.
        #
        # @param klass [Class<Serializer::Resource::Base>, nil] the serializer class
        # @return [Class<Serializer::Resource::Base>, nil]
        #
        # @example
        #   resource_serializer Serializer::Resource::Default
        def resource_serializer(klass = nil)
          @resource_serializer = klass if klass
          @resource_serializer || (superclass.respond_to?(:resource_serializer) && superclass.resource_serializer)
        end

        # @api public
        # The error serializer class.
        #
        # Handles serialization of errors.
        #
        # @param klass [Class<Serializer::Error::Base>, nil] the serializer class
        # @return [Class<Serializer::Error::Base>, nil]
        #
        # @example
        #   error_serializer Serializer::Error::Default
        def error_serializer(klass = nil)
          @error_serializer = klass if klass
          @error_serializer || (superclass.respond_to?(:error_serializer) && superclass.error_serializer)
        end

        # @api public
        # The member wrapper class.
        #
        # @param klass [Class<Wrapper::Member::Base>, nil] the wrapper class
        # @return [Class<Wrapper::Member::Base>, nil]
        #
        # @example
        #   member_wrapper Wrapper::Member::Default
        def member_wrapper(klass = nil)
          @member_wrapper = klass if klass
          @member_wrapper || (superclass.respond_to?(:member_wrapper) && superclass.member_wrapper)
        end

        # @api public
        # The collection wrapper class.
        #
        # @param klass [Class<Wrapper::Collection::Base>, nil] the wrapper class
        # @return [Class<Wrapper::Collection::Base>, nil]
        #
        # @example
        #   collection_wrapper Wrapper::Collection::Default
        def collection_wrapper(klass = nil)
          @collection_wrapper = klass if klass
          @collection_wrapper || (superclass.respond_to?(:collection_wrapper) && superclass.collection_wrapper)
        end

        # @api public
        # The error wrapper class.
        #
        # @param klass [Class<Wrapper::Error::Base>, nil] the wrapper class
        # @return [Class<Wrapper::Error::Base>, nil]
        #
        # @example
        #   error_wrapper Wrapper::Error::Default
        def error_wrapper(klass = nil)
          @error_wrapper = klass if klass
          @error_wrapper || (superclass.respond_to?(:error_wrapper) && superclass.error_wrapper)
        end
      end

      def process_collection(collection, representation_class, request, context: {}, meta: {})
        collection, metadata, serialize_options = apply_capabilities(collection, representation_class, request, wrapper_type: :collection)
        data = self.class.resource_serializer.serialize(representation_class, collection, context:, serialize_options:)
        self.class.collection_wrapper.wrap(data, metadata, representation_class.root_key, meta)
      end

      def process_member(record, representation_class, request, context: {}, meta: {})
        record, metadata, serialize_options = apply_capabilities(record, representation_class, request, wrapper_type: :member)
        data = self.class.resource_serializer.serialize(representation_class, record, context:, serialize_options:)
        self.class.member_wrapper.wrap(data, metadata, representation_class.root_key, meta)
      end

      def process_error(error, representation_class, context: {})
        data = self.class.error_serializer.serialize(error, context:)
        self.class.error_wrapper.wrap(data)
      end

      def register_api(api_class)
        capabilities.each do |capability|
          capability.api_types(api_class)
        end

        error_serializer_class = self.class.error_serializer
        error_serializer_class.new.api_types(api_class)

        build_error_response_body(api_class, error_serializer_class)
      end

      def register_contract(contract_class, representation_class, actions)
        capabilities.each do |capability|
          capability.contract_types(contract_class, representation_class, actions)
        end

        resource_serializer_class = self.class.resource_serializer
        resource_serializer_class.new(representation_class).contract_types(contract_class)

        build_action_responses(contract_class, representation_class, actions)
      end

      def apply_request_transformers(request, phase:)
        run_capability_request_transformers(request, phase:)
      end

      def apply_response_transformers(response)
        run_capability_response_transformers(response)
      end

      def capabilities
        @capabilities ||= self.class.capabilities.map do |klass|
          klass.new({}, adapter_name: self.class.adapter_name)
        end
      end

      private

      def apply_capabilities(data, representation_class, request, wrapper_type:)
        runner = Capability::Runner.new(capabilities, wrapper_type:)
        runner.run(data, representation_class, request)
      end

      def build_action_responses(contract_class, representation_class, actions)
        actions.each_value do |action|
          build_action_response(contract_class, representation_class, action)
        end
      end

      def build_action_response(contract_class, representation_class, action)
        contract_action = contract_class.action(action.name)
        return if contract_action.resets_response?

        case action.name
        when :index
          build_collection_action_response(contract_class, representation_class, action, contract_action)
        when :show, :create, :update
          build_member_action_response(contract_class, representation_class, action, contract_action)
        when :destroy
          contract_action.response { no_content! }
        else
          build_custom_action_response(contract_class, representation_class, action, contract_action)
        end
      end

      def build_member_action_response(contract_class, representation_class, action, contract_action)
        result_wrapper = build_result_wrapper(contract_class, representation_class, action.name, :member)
        member_shape_class = self.class.member_wrapper.shape_class
        data_type = resolve_resource_data_type(representation_class)

        contract_action.response do |response|
          response.result_wrapper = result_wrapper
          response.body do |body|
            member_shape_class.apply(body, representation_class.root_key, capabilities, representation_class, :member, data_type:)
          end
        end
      end

      def build_collection_action_response(contract_class, representation_class, action, contract_action)
        result_wrapper = build_result_wrapper(contract_class, representation_class, action.name, :collection)
        collection_shape_class = self.class.collection_wrapper.shape_class
        data_type = resolve_resource_data_type(representation_class)

        contract_action.response do |response|
          response.result_wrapper = result_wrapper
          response.body do |body|
            collection_shape_class.apply(body, representation_class.root_key, capabilities, representation_class, :collection, data_type:)
          end
        end
      end

      def build_custom_action_response(contract_class, representation_class, action, contract_action)
        if action.method == :delete
          contract_action.response { no_content! }
        elsif action.collection?
          build_collection_action_response(contract_class, representation_class, action, contract_action)
        elsif action.member?
          build_member_action_response(contract_class, representation_class, action, contract_action)
        end
      end

      def build_result_wrapper(contract_class, representation_class, action_name, response_type)
        success_type_name = [action_name, 'success_response_body'].join('_').to_sym

        unless contract_class.type?(success_type_name)
          shape_class = if response_type == :collection
                          self.class.collection_wrapper.shape_class
                        else
                          self.class.member_wrapper.shape_class
                        end
          data_type = resolve_resource_data_type(representation_class)

          contract_class.object(success_type_name) do |object|
            shape_class.apply(object, representation_class.root_key, capabilities, representation_class, response_type, data_type:)
          end
        end

        { error_type: :error_response_body, success_type: contract_class.scoped_type_name(success_type_name) }
      end

      def resolve_resource_data_type(representation_class)
        resource_serializer_class = self.class.resource_serializer
        resource_serializer_class.data_type.call(representation_class)
      end

      def build_error_response_body(api_class, error_serializer_class)
        return if api_class.type?(:error_response_body)

        error_wrapper = self.class.error_wrapper
        shape_class = error_wrapper.shape_class
        return unless shape_class

        data_type = error_serializer_class.data_type

        api_class.object(:error_response_body) do |object|
          shape_class.apply(object, nil, [], nil, :error, data_type:)
        end
      end

      def run_capability_request_transformers(request, phase:)
        transformers = capability_request_transformers.select { |transformer_class| transformer_class.phase == phase }
        result = request
        transformers.each { |transformer_class| result = transformer_class.transform(result) }
        result
      end

      def run_capability_response_transformers(response)
        result = response
        capability_response_transformers.each { |transformer_class| result = transformer_class.transform(result) }
        result
      end

      def capability_request_transformers
        self.class.capabilities.flat_map(&:request_transformers)
      end

      def capability_response_transformers
        self.class.capabilities.flat_map(&:response_transformers)
      end
    end
  end
end
