# frozen_string_literal: true

module Apiwork
  module Adapter
    module Capability
      class Base
        include Configurable

        class_attribute :_api_builder
        class_attribute :_api_builder_block
        class_attribute :_contract_builder
        class_attribute :_contract_builder_block
        class_attribute :_computation_class
        class_attribute :_computation_block

        class << self
          def capability_name(value = nil)
            @capability_name = value.to_sym if value
            @capability_name
          end

          def request_transformer(transformer_class)
            @request_transformers ||= []
            @request_transformers << transformer_class
          end

          def request_transformers
            @request_transformers || []
          end

          def api_builder(klass = nil, &block)
            if klass
              self._api_builder = klass
            elsif block
              self._api_builder_block = block
            end
          end

          def contract_builder(klass = nil, &block)
            if klass
              self._contract_builder = klass
            elsif block
              self._contract_builder_block = block
            end
          end

          def computation(klass = nil, &block)
            if klass
              self._computation_class = klass
            elsif block
              self._computation_block = block
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

          def wrap_computation_block(callable)
            Class.new(Computation::Base) do
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

          def computation_class
            return _computation_class if _computation_class
            return wrap_computation_block(_computation_block) if _computation_block

            nil
          end
        end

        attr_reader :config

        def initialize(config = {})
          merged = self.class.default_options.deep_merge(config)
          @config = Configuration.new(self.class, merged)
        end

        def api_types(api_class, features)
          builder_class = self.class.api_builder_class
          return unless builder_class

          builder_class.new(
            api_class,
            features,
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
          klass = self.class.computation_class
          return nil unless klass

          metadata_block = klass.metadata
          return nil unless metadata_block

          scope = klass.scope
          return nil if scope && scope != type

          object = ::Apiwork::API::Object.new
          shape = Shape.new(object, merged_config(representation_class))
          if metadata_block.arity.positive?
            metadata_block.call(shape)
          else
            shape.instance_exec(&metadata_block)
          end
          object.params.empty? ? nil : object
        end

        def apply(data, representation_class, request, wrapper_type:)
          klass = self.class.computation_class
          return Result.new(data:) unless klass

          scope = klass.scope
          return Result.new(data:) if scope && scope != wrapper_type

          klass.new(
            data,
            representation_class,
            merged_config(representation_class),
            request,
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
      end
    end
  end
end
