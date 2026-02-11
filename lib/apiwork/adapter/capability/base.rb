# frozen_string_literal: true

module Apiwork
  module Adapter
    module Capability
      # @api public
      # Base class for adapter capabilities.
      #
      # A capability encapsulates a specific feature (filtering, pagination, sorting)
      # with its own configuration, transformers, builders, and operations. While each
      # capability is self-contained, all capabilities operate on the same response data
      # in sequence, so their effects combine.
      #
      # @example Filtering capability
      #   class Filtering < Adapter::Capability::Base
      #     capability_name :filtering
      #
      #     option :strategy, type: :symbol, default: :simple
      #
      #     request_transformer RequestTransformer
      #     api_builder APIBuilder
      #     contract_builder ContractBuilder
      #     operation Operation
      #   end
      #
      # @see Adapter::Base#capability
      # @see Configurable#option
      class Base
        include Configurable

        class_attribute :_api_builder
        class_attribute :_api_builder_block
        class_attribute :_contract_builder
        class_attribute :_contract_builder_block
        class_attribute :_operation_class
        class_attribute :_operation_block

        class << self
          # @api public
          # The name for this capability.
          #
          # Used for configuration options, translation keys, and {Adapter::Base.skip_capability}.
          #
          # @param value [Symbol, nil] (nil)
          #   The capability name.
          # @return [Symbol, nil]
          def capability_name(value = nil)
            @capability_name = value.to_sym if value
            @capability_name
          end

          # @api public
          # Registers a request transformer for this capability.
          #
          # @param transformer_class [Class<Transformer::Request::Base>]
          #   The transformer class.
          # @return [void]
          # @see Transformer::Request::Base
          def request_transformer(transformer_class)
            @request_transformers ||= []
            @request_transformers << transformer_class
          end

          def request_transformers
            @request_transformers || []
          end

          # @api public
          # Registers a response transformer for this capability.
          #
          # @param transformer_class [Class<Transformer::Response::Base>]
          #   The transformer class.
          # @return [void]
          # @see Transformer::Response::Base
          def response_transformer(transformer_class)
            @response_transformers ||= []
            @response_transformers << transformer_class
          end

          def response_transformers
            @response_transformers || []
          end

          # @api public
          # Registers an API builder for this capability.
          #
          # API builders run once per API at initialization time to register
          # shared types used across all contracts.
          #
          # @param klass [Class<Builder::API::Base>, nil] (nil)
          #   The builder class.
          # @yield block evaluated in {Builder::API::Base} context
          # @return [void]
          # @see Builder::API::Base
          def api_builder(klass = nil, &block)
            if klass
              self._api_builder = klass
            elsif block
              self._api_builder_block = block
            end
          end

          # @api public
          # Registers a contract builder for this capability.
          #
          # Contract builders run per contract to add capability-specific
          # parameters and response shapes.
          #
          # @param klass [Class<Builder::Contract::Base>, nil] (nil)
          #   The builder class.
          # @yield block evaluated in {Builder::Contract::Base} context
          # @return [void]
          # @see Builder::Contract::Base
          def contract_builder(klass = nil, &block)
            if klass
              self._contract_builder = klass
            elsif block
              self._contract_builder_block = block
            end
          end

          # @api public
          # Registers an operation for this capability.
          #
          # Operations run at request time to process data based on
          # request parameters.
          #
          # @param klass [Class<Operation::Base>, nil] (nil)
          #   The operation class.
          # @yield block evaluated in {Operation::Base} context
          # @return [void]
          # @see Operation::Base
          def operation(klass = nil, &block)
            if klass
              self._operation_class = klass
            elsif block
              self._operation_block = block
            end
          end

          def wrap_api_builder_block(callable)
            Class.new(Builder::API::Base) do
              define_method(:build) do
                callable.arity.positive? ? callable.call(self) : instance_exec(&callable)
              end
            end
          end

          def wrap_contract_builder_block(callable)
            Class.new(Builder::Contract::Base) do
              define_method(:build) do
                callable.arity.positive? ? callable.call(self) : instance_exec(&callable)
              end
            end
          end

          def wrap_operation_block(callable)
            Class.new(Operation::Base) do
              define_method(:apply) do
                callable.arity.positive? ? callable.call(self) : instance_exec(&callable)
              end
            end
          end

          def api_builder_class
            return _api_builder if _api_builder
            return wrap_api_builder_block(_api_builder_block) if _api_builder_block

            nil
          end

          def contract_builder_class
            return _contract_builder if _contract_builder
            return wrap_contract_builder_block(_contract_builder_block) if _contract_builder_block

            nil
          end

          def operation_class
            return _operation_class if _operation_class
            return wrap_operation_block(_operation_block) if _operation_block

            nil
          end
        end

        attr_reader :adapter_name,
                    :config

        def initialize(config = {}, adapter_name: nil)
          merged = self.class.default_options.deep_merge(config)
          @config = Configuration.new(self.class, merged)
          @adapter_name = adapter_name
        end

        def api_types(api_class)
          builder_class = self.class.api_builder_class
          return unless builder_class

          builder_class.new(
            api_class,
            capability_name: self.class.capability_name,
            options: config,
          ).build
        end

        def contract_types(contract_class, representation_class, actions)
          builder_class = self.class.contract_builder_class
          return unless builder_class

          builder_class.new(contract_class, representation_class, actions, merged_config(representation_class)).build
        end

        def shape(representation_class, type)
          klass = self.class.operation_class
          return nil unless klass

          metadata_shape_class = klass.metadata_shape
          return nil unless metadata_shape_class

          scope = klass.target
          return nil if scope && scope != type

          object = ::Apiwork::API::Object.new
          metadata_shape_class.apply(object, merged_config(representation_class))
          object.params.empty? ? nil : object
        end

        def apply(data, representation_class, request, wrapper_type:)
          klass = self.class.operation_class
          return Result.new(data:) unless klass

          scope = klass.target
          return Result.new(data:) if scope && scope != wrapper_type

          klass.new(
            data,
            representation_class,
            merged_config(representation_class),
            request,
            translation_context: build_translation_context(representation_class),
          ).apply
        end

        private

        def merged_config(representation_class)
          capability_name = self.class.capability_name
          return config unless capability_name

          representation_config = representation_class.adapter_config.public_send(capability_name).to_h
          config.merge(representation_config)
        rescue ConfigurationError
          config
        end

        def build_translation_context(representation_class)
          locale_key = representation_class.api_class.locale_key

          {
            locale_key:,
            adapter_name: adapter_name,
            capability_name: self.class.capability_name,
          }
        end
      end
    end
  end
end
