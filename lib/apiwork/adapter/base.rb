# frozen_string_literal: true

module Apiwork
  module Adapter
    # @api public
    # Base class for adapters.
    #
    # Subclass to create custom adapters with different response formats.
    # Override {#prepare_record}, {#prepare_collection}, {#render_record},
    # {#render_collection}, and {#render_error} to customize behavior.
    #
    # @example Custom adapter
    #   class BillingAdapter < Apiwork::Adapter::Base
    #     adapter_name :billing
    #
    #     def render_record(data, schema_class, state)
    #       { data: data, meta: { adapter: 'billing' } }
    #     end
    #
    #     def render_error(issues, layer, state)
    #       { errors: issues.map(&:to_h) }
    #     end
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
        # Registers a feature for this adapter.
        #
        # Features are self-contained concerns (pagination, filtering, etc.)
        # that handle both introspection and runtime behavior.
        #
        # @param klass [Class] a Feature subclass
        # @return [void]
        #
        # @example
        #   feature Pagination
        #   feature Filtering
        def feature(klass)
          @features ||= []
          @features << klass

          return unless klass.options.any?

          name = klass.feature_name
          options[name] = Configuration::Option.new(name, :hash, children: klass.options)
        end

        # @api public
        # Skips an inherited feature by name.
        #
        # @param name [Symbol] the feature_name to skip
        # @return [void]
        #
        # @example
        #   skip_feature :pagination
        def skip_feature(name)
          @skipped_features ||= []
          @skipped_features << name.to_sym
        end

        def features
          inherited = superclass.respond_to?(:features) ? superclass.features : []
          skipped = @skipped_features || []
          all = (inherited + (@features || [])).uniq
          all.reject { |f| skipped.include?(f.feature_name) }
        end

        # @api public
        # Sets or gets the resource envelope class.
        #
        # The resource envelope handles both single records and collections
        # for a given schema class.
        #
        # @param klass [Class] an Envelope::Resource subclass (optional)
        # @return [Class, nil]
        #
        # @example
        #   resource_envelope ResourceEnvelope
        def resource_envelope(klass = nil)
          @resource_envelope = klass if klass
          @resource_envelope || (superclass.respond_to?(:resource_envelope) && superclass.resource_envelope)
        end

        # @api public
        # Sets or gets the error envelope class.
        #
        # @param klass [Class] an Envelope::Error subclass (optional)
        # @return [Class, nil]
        #
        # @example
        #   error_envelope ErrorEnvelope
        def error_envelope(klass = nil)
          @error_envelope = klass if klass
          @error_envelope || (superclass.respond_to?(:error_envelope) && superclass.error_envelope)
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
        envelope = self.class.resource_envelope.new(schema_class)
        prepared = envelope.prepare_collection(collection, state)
        result, metadata = apply_features(prepared, state)
        serialized = envelope.serialize_collection(result[:data], state)
        envelope.render_collection(serialized, metadata, state)
      end

      def process_record(record, schema_class, state)
        envelope = self.class.resource_envelope.new(schema_class)
        prepared = envelope.prepare_record(record, state)
        serialized = envelope.serialize_record(prepared, state)
        envelope.render_record(serialized, state)
      end

      def process_error(layer, issues, state)
        envelope = self.class.error_envelope.new
        prepared = prepare_error(issues, layer, state)
        envelope.render(prepared, layer, state)
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

      def register_api(registrar, capabilities)
        feature_instances.each do |feature|
          feature.api(registrar, capabilities)
        end

        error_envelope_class = self.class.error_envelope
        error_envelope_class.new.define(registrar) if error_envelope_class # rubocop:disable Style/SafeNavigation
      end

      def register_contract(registrar, schema_class, actions)
        feature_instances.each do |feature|
          feature.contract(registrar, schema_class)
        end

        resource_envelope_class = self.class.resource_envelope
        resource_envelope_class.new(schema_class).define(registrar, actions) if resource_envelope_class # rubocop:disable Style/SafeNavigation
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

      def feature_instances
        @feature_instances ||= self.class.features.map do |klass|
          config = adapter_config_for(klass.feature_name)
          klass.new(config)
        end
      end

      private

      def apply_features(data, state)
        metadata = {}
        result = feature_instances.reduce(data) do |current, feature|
          processed = feature.apply(current, state)
          metadata.merge!(feature.metadata(processed, state))
          processed
        end
        [result, metadata]
      end

      def adapter_config_for(feature_name)
        {}
      end
    end
  end
end
