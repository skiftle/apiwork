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
        # The adapter name for this adapter.
        #
        # @param value [Symbol, String, nil] (nil)
        #   The adapter name.
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
        # @param klass [Class<Capability::Base>]
        #   The capability class.
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
        # @param name [Symbol]
        #   The capability name to skip.
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
        # Sets the serializer class for records and collections.
        #
        # @param klass [Class<Serializer::Resource::Base>, nil] (nil)
        #   The serializer class.
        # @return [Class<Serializer::Resource::Base>, nil]
        #
        # @example
        #   resource_serializer Serializer::Resource::Default
        def resource_serializer(klass = nil)
          if klass
            validate_class_setter!(:resource_serializer, klass, Serializer::Resource::Base, 'Serializer')
            @resource_serializer = klass
          end
          @resource_serializer || (superclass.respond_to?(:resource_serializer) && superclass.resource_serializer)
        end

        # @api public
        # Sets the serializer class for errors.
        #
        # @param klass [Class<Serializer::Error::Base>, nil] (nil)
        #   The serializer class.
        # @return [Class<Serializer::Error::Base>, nil]
        #
        # @example
        #   error_serializer Serializer::Error::Default
        def error_serializer(klass = nil)
          if klass
            validate_class_setter!(:error_serializer, klass, Serializer::Error::Base, 'Serializer')
            @error_serializer = klass
          end
          @error_serializer || (superclass.respond_to?(:error_serializer) && superclass.error_serializer)
        end

        # @api public
        # Sets the wrapper class for single-record responses.
        #
        # @param klass [Class<Wrapper::Member::Base>, nil] (nil)
        #   The wrapper class.
        # @return [Class<Wrapper::Member::Base>, nil]
        #
        # @example
        #   member_wrapper Wrapper::Member::Default
        def member_wrapper(klass = nil)
          if klass
            validate_class_setter!(:member_wrapper, klass, Wrapper::Member::Base, 'Wrapper')
            @member_wrapper = klass
          end
          @member_wrapper || (superclass.respond_to?(:member_wrapper) && superclass.member_wrapper)
        end

        # @api public
        # Sets the wrapper class for collection responses.
        #
        # @param klass [Class<Wrapper::Collection::Base>, nil] (nil)
        #   The wrapper class.
        # @return [Class<Wrapper::Collection::Base>, nil]
        #
        # @example
        #   collection_wrapper Wrapper::Collection::Default
        def collection_wrapper(klass = nil)
          if klass
            validate_class_setter!(:collection_wrapper, klass, Wrapper::Collection::Base, 'Wrapper')
            @collection_wrapper = klass
          end
          @collection_wrapper || (superclass.respond_to?(:collection_wrapper) && superclass.collection_wrapper)
        end

        # @api public
        # Sets the wrapper class for error responses.
        #
        # @param klass [Class<Wrapper::Error::Base>, nil] (nil)
        #   The wrapper class.
        # @return [Class<Wrapper::Error::Base>, nil]
        #
        # @example
        #   error_wrapper Wrapper::Error::Default
        def error_wrapper(klass = nil)
          if klass
            validate_class_setter!(:error_wrapper, klass, Wrapper::Error::Base, 'Wrapper')
            @error_wrapper = klass
          end
          @error_wrapper || (superclass.respond_to?(:error_wrapper) && superclass.error_wrapper)
        end

        private

        def validate_class_setter!(name, klass, base_class, label)
          unless klass.is_a?(Class)
            raise ConfigurationError,
                  "#{name} must be a #{label} class, got #{klass.class}. " \
                  "Use: #{name} Example (not 'Example' or :example)"
          end
          return if klass < base_class

          raise ConfigurationError,
                "#{name} must be a #{label} class (subclass of #{base_class.name}), " \
                "got #{klass}"
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

      def register_contract(contract_class, representation_class, resource: nil)
        resource_actions = resource ? resource.actions : {}

        capabilities.each do |capability|
          capability.contract_types(contract_class, representation_class, resource_actions)
        end

        self.class.resource_serializer.new(representation_class).contract_types(contract_class)

        build_action_responses(contract_class, representation_class, resource_actions, resource.name) if resource
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
        Capability::Runner.run(
          capabilities,
          data:,
          representation_class:,
          request:,
          wrapper_type:,
        )
      end

      def build_action_responses(contract_class, representation_class, actions, resource_name)
        actions.each_value do |action|
          build_action_response(contract_class, representation_class, action, resource_name)
        end
      end

      def build_action_response(contract_class, representation_class, action, resource_name)
        contract_action = contract_class.action(action.name)
        return if contract_action.resets_response?

        case action.name
        when :index
          build_collection_action_response(contract_class, representation_class, action, contract_action, resource_name)
        when :show, :create, :update
          build_member_action_response(contract_class, representation_class, action, contract_action, resource_name)
        when :destroy
          contract_action.response { no_content! }
        else
          build_custom_action_response(contract_class, representation_class, action, contract_action, resource_name)
        end

        build_request_query_type(contract_class, action.name, contract_action, resource_name)
        build_request_body_type(contract_class, action.name, contract_action, resource_name)
        build_request_type(contract_class, action.name, contract_action, resource_name)
        build_response_type(contract_class, action.name, contract_action, resource_name)
      end

      def build_member_action_response(contract_class, representation_class, action, contract_action, resource_name)
        build_response_body_type(contract_class, representation_class, action.name, :member, resource_name)
        member_shape_class = self.class.member_wrapper.shape_class
        data_type = resolve_resource_data_type(representation_class)

        contract_action.response do |response|
          response.body do |body|
            member_shape_class.apply(body, representation_class.root_key, capabilities, representation_class, :member, data_type:)
          end
        end
      end

      def build_collection_action_response(contract_class, representation_class, action, contract_action, resource_name)
        build_response_body_type(contract_class, representation_class, action.name, :collection, resource_name)
        collection_shape_class = self.class.collection_wrapper.shape_class
        data_type = resolve_resource_data_type(representation_class)

        contract_action.response do |response|
          response.body do |body|
            collection_shape_class.apply(body, representation_class.root_key, capabilities, representation_class, :collection, data_type:)
          end
        end
      end

      def build_custom_action_response(contract_class, representation_class, action, contract_action, resource_name)
        if action.method == :delete
          contract_action.response { no_content! }
        elsif action.collection?
          build_collection_action_response(contract_class, representation_class, action, contract_action, resource_name)
        elsif action.member?
          build_member_action_response(contract_class, representation_class, action, contract_action, resource_name)
        end
      end

      def build_response_body_type(contract_class, representation_class, action_name, response_type, resource_name)
        type_name = build_action_type_name(resource_name, action_name, 'response_body')
        api_class = contract_class.api_class
        return if api_class.type_registry.key?(type_name)

        shape_class = if response_type == :collection
                        self.class.collection_wrapper.shape_class
                      else
                        self.class.member_wrapper.shape_class
                      end
        data_type = resolve_resource_data_type(representation_class)

        api_class.register_object(type_name) do |object|
          shape_class.apply(object, representation_class.root_key, capabilities, representation_class, response_type, data_type:)
        end
      end

      def build_request_query_type(contract_class, action_name, contract_action, resource_name)
        request = contract_action.request
        return unless request.query.params.any?

        type_name = build_action_type_name(resource_name, action_name, 'request_query')
        api_class = contract_class.api_class
        return if api_class.type_registry.key?(type_name)

        api_class.register_object(type_name) do |object|
          request.query.params.each { |name, param| object.param(name, **normalize_request_param(param)) }
        end
      end

      def build_request_body_type(contract_class, action_name, contract_action, resource_name)
        request = contract_action.request
        return unless request.body.params.any?

        type_name = build_action_type_name(resource_name, action_name, 'request_body')
        api_class = contract_class.api_class
        return if api_class.type_registry.key?(type_name)

        api_class.register_object(type_name) do |object|
          request.body.params.each { |name, param| object.param(name, **normalize_request_param(param)) }
        end
      end

      def build_request_type(contract_class, action_name, contract_action, resource_name)
        request = contract_action.request
        return unless request.query.params.any? || request.body.params.any?

        type_name = build_action_type_name(resource_name, action_name, 'request')
        api_class = contract_class.api_class
        return if api_class.type_registry.key?(type_name)

        query_type_name = build_action_type_name(resource_name, action_name, 'request_query')
        body_type_name = build_action_type_name(resource_name, action_name, 'request_body')

        api_class.register_object(type_name) do |object|
          object.param(:query, type: query_type_name) if request.query.params.any?
          object.param(:body, type: body_type_name) if request.body.params.any?
        end
      end

      def build_response_type(contract_class, action_name, contract_action, resource_name)
        type_name = build_action_type_name(resource_name, action_name, 'response')
        api_class = contract_class.api_class
        return if api_class.type_registry.key?(type_name)

        body_type_name = build_action_type_name(resource_name, action_name, 'response_body')

        if contract_action.response.no_content?
          api_class.register_object(type_name) { |_object| }
        else
          api_class.register_object(type_name) do |object|
            object.param(:body, type: body_type_name)
          end
        end
      end

      def build_action_type_name(resource_name, action_name, suffix)
        [resource_name, action_name, suffix].join('_').to_sym
      end

      def normalize_request_param(param)
        options = param.except(:name, :custom_type, :union, :partial)
        options[:type] = param[:custom_type] if param[:custom_type]
        options[:shape] = param[:union] if param[:union]
        options
      end

      def resolve_resource_data_type(representation_class)
        self.class.resource_serializer.data_type.call(representation_class)
      end

      def build_error_response_body(api_class, error_serializer_class)
        return if api_class.type?(:error_response_body)

        shape_class = self.class.error_wrapper.shape_class
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
