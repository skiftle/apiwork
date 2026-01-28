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
        # Sets or gets the serialization class.
        #
        # Serialization defines API objects (resources, errors) and handles serialization.
        #
        # @param klass [Class] a Serialization::Base subclass (optional)
        # @return [Class, nil]
        #
        # @example
        #   serialization Serialization::Default
        def serialization(klass = nil)
          @serialization = klass if klass
          @serialization || (superclass.respond_to?(:serialization) && superclass.serialization)
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

      def process_collection(collection, representation_class, request, meta: {}, user_context: {})
        result, metadata = apply_capabilities({ data: collection }, representation_class, request, document_type: :collection)
        serialize_options = result[:serialize_options] || {}

        rep = serialization_instance(representation_class)
        serialized = rep.serialize_resource(result[:data], serialize_options:, context: user_context)

        self.class.collection_document.new(serialized, representation_class, metadata, capabilities, meta).build
      end

      def process_record(record, representation_class, request, meta: {}, user_context: {})
        result, metadata = apply_capabilities({ data: record }, representation_class, request, document_type: :record)
        serialize_options = result[:serialize_options] || {}

        rep = serialization_instance(representation_class)
        serialized = rep.serialize_resource(result[:data], serialize_options:, context: user_context)

        self.class.record_document.new(serialized, representation_class, metadata, capabilities, meta).build
      end

      def process_error(error, representation_class, user_context: {})
        rep = serialization_instance(representation_class)
        serialized = rep.serialize_error(error, context: user_context)

        self.class.error_document.new(serialized).build
      end

      def register_api(api_class, features)
        capabilities.each do |capability|
          capability.api_types(api_class, features)
        end

        serialization_class = self.class.serialization
        serialization_class&.new(nil)&.api(api_class, features)
      end

      def register_contract(contract_class, representation_class, actions)
        capabilities.each do |capability|
          capability.contract_types(contract_class, representation_class, actions)
        end

        serialization_class = self.class.serialization
        serialization_class&.new(representation_class)&.contract(contract_class, representation_class, actions)

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

      def serialization_instance(representation_class)
        self.class.serialization.new(representation_class)
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

        contract_action.response do |response|
          response.result_wrapper = result_wrapper
          response.body do |body|
            record_shape_class.build(body, representation_class, capabilities, :record)
          end
        end
      end

      def build_collection_action_response(contract_class, representation_class, action, contract_action)
        result_wrapper = build_result_wrapper(contract_class, representation_class, action.name, :collection)
        collection_shape_class = self.class.collection_document.shape_class

        contract_action.response do |response|
          response.result_wrapper = result_wrapper
          response.body do |body|
            collection_shape_class.build(body, representation_class, capabilities, :collection)
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

          contract_class.object(success_type_name) do |object|
            shape_class.build(object, representation_class, capabilities, response_type)
          end
        end

        { error_type: :error_response_body, success_type: contract_class.scoped_type_name(success_type_name) }
      end
    end
  end
end
