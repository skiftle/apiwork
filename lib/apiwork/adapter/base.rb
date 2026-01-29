# frozen_string_literal: true

module Apiwork
  module Adapter
    # @api public
    # Base class for adapters.
    #
    # Subclass to create custom adapters with different response formats.
    # Configure with {representation} for serialization and document classes for response wrapping.
    #
    # @example Custom adapter
    #   class BillingAdapter < Apiwork::Adapter::Base
    #     adapter_name :billing
    #
    #     representation BillingRepresentation
    #     record_document BillingRecordDocument
    #     collection_document BillingCollectionDocument
    #     error_document BillingErrorDocument
    #   end
    class Base
      include Configurable

      class << self
        # @api public
        # Sets or gets the adapter name.
        #
        # @param value [Symbol, String] adapter name (optional)
        # @return [Symbol, nil]
        #
        # @example
        #   adapter_name :billing
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
        # @param klass [Class] a Capability::Base subclass
        # @return [void]
        #
        # @example
        #   capability Pagination
        #   capability Filtering
        def capability(klass)
          @capabilities ||= []
          @capabilities << klass

          klass.request_transformers.each do |transformer|
            transform_request transformer[:klass], post: transformer[:post]
          end

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
          all.reject { |c| skipped.include?(c.capability_name) }
        end

        # @api public
        # Sets or gets the resource serializer class.
        #
        # Resource serializer handles serialization of records and collections.
        #
        # @param klass [Class] a Serializer::Resource::Base subclass (optional)
        # @return [Class, nil]
        #
        # @example
        #   resource_serializer Serializer::Resource::Default
        def resource_serializer(klass = nil)
          @resource_serializer = klass if klass
          @resource_serializer || (superclass.respond_to?(:resource_serializer) && superclass.resource_serializer)
        end

        # @api public
        # Sets or gets the error serializer class.
        #
        # Error serializer handles serialization of errors.
        #
        # @param klass [Class] a Serializer::Error::Base subclass (optional)
        # @return [Class, nil]
        #
        # @example
        #   error_serializer Serializer::Error::Default
        def error_serializer(klass = nil)
          @error_serializer = klass if klass
          @error_serializer || (superclass.respond_to?(:error_serializer) && superclass.error_serializer)
        end

        # @api public
        # Sets or gets the record document class.
        #
        # @param klass [Class] a Document::Base subclass (optional)
        # @return [Class]
        #
        # @example
        #   record_document CustomRecordDocument
        def record_document(klass = nil)
          @record_document = klass if klass
          @record_document || (superclass.respond_to?(:record_document) && superclass.record_document)
        end

        # @api public
        # Sets or gets the collection document class.
        #
        # @param klass [Class] a Document::Base subclass (optional)
        # @return [Class]
        #
        # @example
        #   collection_document CustomCollectionDocument
        def collection_document(klass = nil)
          @collection_document = klass if klass
          @collection_document || (superclass.respond_to?(:collection_document) && superclass.collection_document)
        end

        # @api public
        # Sets or gets the error document class.
        #
        # @param klass [Class] a Document::Base subclass (optional)
        # @return [Class]
        #
        # @example
        #   error_document CustomErrorDocument
        def error_document(klass = nil)
          @error_document = klass if klass
          @error_document || (superclass.respond_to?(:error_document) && superclass.error_document)
        end

        # @api public
        # Registers request transformers.
        #
        # Use `post: false` (default) for pre-validation transforms.
        # Use `post: true` for post-validation transforms.
        #
        # @param transformers [Array<Class>] transformer classes with `.transform(request, api_class:)`
        # @param post [Boolean] run after validation (default: false)
        # @return [void]
        #
        # @example Pre-validation transform
        #   transform_request KeyNormalizer
        #
        # @example Post-validation transform
        #   transform_request OpFieldTransformer, post: true
        def transform_request(*transformers, post: false)
          @request ||= Hook::Request.new
          transformers.each do |transformer|
            @request.add_transform(transformer, post:)
          end
        end

        # @api public
        # Registers response transformers.
        #
        # Use `post: false` (default) for pre-serialization transforms.
        # Use `post: true` for post-serialization transforms.
        #
        # @param transformers [Array<Class>] transformer classes with `.transform(response, api_class:)`
        # @param post [Boolean] run after other transforms (default: false)
        # @return [void]
        #
        # @example
        #   transform_response KeyTransformer
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

      def process_collection(collection, representation_class, request, context: {}, meta: {})
        collection, metadata, serialize_options = apply_capabilities(collection, representation_class, request, document_type: :collection)

        serializer = resource_serializer_instance(representation_class)
        data = serializer.serialize(collection, context:, serialize_options:)

        self.class.collection_document.new(data, metadata, representation_class.root_key, capabilities, meta).json
      end

      def process_record(record, representation_class, request, context: {}, meta: {})
        record, metadata, serialize_options = apply_capabilities(record, representation_class, request, document_type: :record)

        serializer = resource_serializer_instance(representation_class)
        data = serializer.serialize(record, context:, serialize_options:)

        self.class.record_document.new(data, metadata, representation_class.root_key, capabilities, meta).json
      end

      def process_error(error, representation_class, context: {})
        serializer = error_serializer_instance
        data = serializer.serialize(error, context:)

        self.class.error_document.new(data).json
      end

      def register_api(api_class, features)
        capabilities.each do |capability|
          capability.api_types(api_class, features)
        end

        error_serializer_class = self.class.error_serializer
        error_serializer_class.new.api_types(api_class, features)

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

      def normalize_request(request, api_class:)
        self.class.request.run_before_transforms(request, api_class:)
      end

      def prepare_request(request, api_class:)
        self.class.request.run_after_transforms(request, api_class:)
      end

      def transform_response_output(response, api_class:)
        self.class.response.run_transforms(response, api_class:)
      end

      def build_features(structure)
        Features.new(structure)
      end

      def capabilities
        @capabilities ||= self.class.capabilities.map do |klass|
          klass.new({})
        end
      end

      private

      def resource_serializer_instance(representation_class)
        self.class.resource_serializer.new(representation_class)
      end

      def error_serializer_instance
        self.class.error_serializer.new
      end

      def apply_capabilities(data, representation_class, request, document_type:)
        runner = Capability::Runner.new(capabilities, document_type:)
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
          build_record_action_response(contract_class, representation_class, action, contract_action)
        when :destroy
          contract_action.response { no_content! }
        else
          build_custom_action_response(contract_class, representation_class, action, contract_action)
        end
      end

      def build_record_action_response(contract_class, representation_class, action, contract_action)
        result_wrapper = build_result_wrapper(contract_class, representation_class, action.name, :record)
        record_shape_class = self.class.record_document.shape_class
        data_type = resolve_resource_data_type(representation_class)

        contract_action.response do |response|
          response.result_wrapper = result_wrapper
          response.body do |body|
            record_shape_class.build(body, representation_class.root_key, capabilities, representation_class, :record, data_type:)
          end
        end
      end

      def build_collection_action_response(contract_class, representation_class, action, contract_action)
        result_wrapper = build_result_wrapper(contract_class, representation_class, action.name, :collection)
        collection_shape_class = self.class.collection_document.shape_class
        data_type = resolve_resource_data_type(representation_class)

        contract_action.response do |response|
          response.result_wrapper = result_wrapper
          response.body do |body|
            collection_shape_class.build(body, representation_class.root_key, capabilities, representation_class, :collection, data_type:)
          end
        end
      end

      def build_custom_action_response(contract_class, representation_class, action, contract_action)
        if action.method == :delete
          contract_action.response { no_content! }
        elsif action.collection?
          build_collection_action_response(contract_class, representation_class, action, contract_action)
        elsif action.member?
          build_record_action_response(contract_class, representation_class, action, contract_action)
        end
      end

      def build_result_wrapper(contract_class, representation_class, action_name, response_type)
        success_type_name = :"#{action_name}_success_response_body"

        unless contract_class.type?(success_type_name)
          shape_class = if response_type == :collection
                          self.class.collection_document.shape_class
                        else
                          self.class.record_document.shape_class
                        end
          data_type = resolve_resource_data_type(representation_class)

          contract_class.object(success_type_name) do |object|
            shape_class.build(object, representation_class.root_key, capabilities, representation_class, response_type, data_type:)
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

        error_document = self.class.error_document
        shape_class = error_document.shape_class
        return unless shape_class

        data_type = error_serializer_class.data_type

        api_class.object(:error_response_body, extends: data_type) do |object|
          shape_class.build(object, nil, [], nil, :error, data_type:)
        end
      end
    end
  end
end
