# frozen_string_literal: true

module Apiwork
  module Adapter
    # @api public
    # Base class for adapters.
    #
    # Subclass to create custom adapters with different response formats.
    # Configure with {representation} for serialization and {document} for response wrapping.
    #
    # @example Custom adapter
    #   class BillingAdapter < Apiwork::Adapter::Base
    #     adapter_name :billing
    #
    #     representation BillingRepresentation
    #     document BillingDocument
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
        # Sets or gets the representation class.
        #
        # Representation defines API objects (resources, errors) and handles serialization.
        #
        # @param klass [Class] a Representation::Base subclass (optional)
        # @return [Class, nil]
        #
        # @example
        #   representation StandardRepresentation
        def representation(klass = nil)
          @representation = klass if klass
          @representation || (superclass.respond_to?(:representation) && superclass.representation)
        end

        # @api public
        # Sets or gets the document class.
        #
        # Document defines response envelopes and wraps serialized data.
        #
        # @param klass [Class] a Document::Base subclass (optional)
        # @return [Class, nil]
        #
        # @example
        #   document StandardDocument
        def document(klass = nil)
          @document = klass if klass
          @document || (superclass.respond_to?(:document) && superclass.document)
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

      def process_collection(collection, schema_class, state)
        result, metadata = apply_capabilities({ data: collection }, state)
        serialize_options = result[:serialize_options] || {}

        rep = representation_instance(schema_class)
        doc = document_instance(schema_class)

        serialized = rep.serialize_resource(result[:data], serialize_options:, context: state.context)
        doc.build_collection_response(serialized, metadata, state)
      end

      def process_record(record, schema_class, state)
        result, metadata = apply_capabilities({ data: record }, state)
        serialize_options = result[:serialize_options] || {}

        rep = representation_instance(schema_class)
        doc = document_instance(schema_class)

        serialized = rep.serialize_resource(result[:data], serialize_options:, context: state.context)
        doc.build_record_response(serialized, metadata, state)
      end

      def process_error(layer, issues, state)
        prepared = prepare_error(issues, layer, state)

        rep = representation_instance(state.schema_class)
        doc = document_instance(state.schema_class)

        serialized = prepared.map { |issue| rep.serialize_error(issue, context: state.context) }
        doc.build_error_response(serialized, layer, state)
      end

      # @api public
      # Prepares error issues before rendering.
      #
      # Override to transform or enrich error data.
      #
      # @param issues [Array<Issue>] error issues
      # @param _layer [Symbol] error layer (:contract, :domain, :http)
      # @param _state [Adapter::RenderState] render context
      # @return [Array<Issue>] the prepared issues
      def prepare_error(issues, _layer, _state)
        issues
      end

      def register_api(registrar, adapter_capabilities)
        capability_instances.each do |capability|
          capability.api(registrar, adapter_capabilities)
        end

        representation_class = self.class.representation
        representation_class&.new(nil)&.api(registrar, adapter_capabilities)
      end

      def register_contract(registrar, schema_class, actions)
        capability_instances.each do |capability|
          capability.contract(registrar, schema_class, actions)
        end

        representation_class = self.class.representation
        representation_class&.new(schema_class)&.contract(registrar, schema_class, actions)

        document_class = self.class.document
        document_class&.new(schema_class)&.contract(registrar, schema_class, actions, capabilities: capability_instances)
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

      def capability_instances
        @capability_instances ||= self.class.capabilities.map do |klass|
          config = adapter_config_for(klass.capability_name)
          klass.new(config)
        end
      end

      private

      def representation_instance(schema_class)
        self.class.representation.new(schema_class)
      end

      def document_instance(schema_class)
        self.class.document.new(schema_class)
      end

      def apply_capabilities(data, state)
        runner = CapabilityRunner.new(capability_instances)
        runner.run(data, state)
      end

      def adapter_config_for(capability_name)
        {}
      end
    end
  end
end
