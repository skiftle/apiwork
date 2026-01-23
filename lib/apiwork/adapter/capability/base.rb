# frozen_string_literal: true

module Apiwork
  module Adapter
    module Capability
      class Base
        include Configurable

        class_attribute :_api_class
        class_attribute :_api_block
        class_attribute :_contract_class
        class_attribute :_contract_block
        class_attribute :_envelope_class
        class_attribute :_envelope_block
        class_attribute :_result_class
        class_attribute :_result_block

        class << self
          def capability_name(value = nil)
            @capability_name = value.to_sym if value
            @capability_name
          end

          def request_transformer(klass, post: false)
            @request_transformers ||= []
            @request_transformers << { klass:, post: }
          end

          def request_transformers
            @request_transformers || []
          end

          def api(klass = nil, &block)
            if klass
              self._api_class = klass
            elsif block
              self._api_block = block
            end
          end

          def contract(klass = nil, &block)
            if klass
              self._contract_class = klass
            elsif block
              self._contract_block = block
            end
          end

          def envelope(klass = nil, &block)
            if klass
              self._envelope_class = klass
            elsif block
              self._envelope_block = block
            end
          end

          def result(klass = nil, &block)
            if klass
              self._result_class = klass
            elsif block
              self._result_block = block
            end
          end

          def wrap_api_block(callable)
            Class.new(API::Base) do
              define_method(:build) do
                instance_exec(&callable)
              end
            end
          end

          def wrap_contract_block(callable)
            Class.new(Contract::Base) do
              define_method(:build) do
                instance_exec(&callable)
              end
            end
          end

          def wrap_envelope_block(callable)
            Class.new(Envelope::Base) do
              define_method(:build) do
                instance_exec(&callable)
              end
            end
          end

          def wrap_result_block(callable)
            Class.new(Result::Base) do
              define_method(:apply) do
                instance_exec(&callable)
              end
            end
          end

          def api_class
            return _api_class if _api_class
            return wrap_api_block(_api_block) if _api_block

            nil
          end

          def contract_class
            return _contract_class if _contract_class
            return wrap_contract_block(_contract_block) if _contract_block

            nil
          end

          def envelope_class
            return _envelope_class if _envelope_class
            return wrap_envelope_block(_envelope_block) if _envelope_block

            nil
          end

          def result_class
            return _result_class if _result_class
            return wrap_result_block(_result_block) if _result_block

            nil
          end
        end

        attr_reader :config

        def initialize(config = {})
          merged = self.class.default_options.deep_merge(config)
          @config = Configuration.new(self.class, merged)
        end

        def api_types(registrar, features)
          klass = self.class.api_class
          return unless klass

          context = API::Context.new(
            features:,
            registrar:,
            capability_name: self.class.capability_name,
            options: config,
          )
          klass.new(context).build
        end

        def contract_types(registrar, schema_class, actions)
          klass = self.class.contract_class
          return unless klass

          context = Contract::Context.new(
            actions:,
            registrar:,
            schema_class:,
            options: merged_config(schema_class),
          )
          klass.new(context).build
        end

        def shape(shape_context)
          klass = self.class.envelope_class
          return nil unless klass

          target = ::Apiwork::API::Object.new
          context = Envelope::Context.new(
            target:,
            document_type: shape_context.type,
            options: merged_config(shape_context.schema_class),
            schema_class: shape_context.schema_class,
          )
          klass.new(context).build
          target.params.empty? ? nil : target
        end

        def apply(data, adapter_context)
          klass = self.class.result_class
          return ApplyResult.new(data:) unless klass

          context = Result::Context.new(
            data:,
            options: merged_config(adapter_context.schema_class),
            request: adapter_context.request,
            schema_class: adapter_context.schema_class,
          )
          klass.new(context).apply
        end

        private

        def merged_config(schema_class)
          capability_name = self.class.capability_name
          return config unless capability_name

          schema_config = schema_class.adapter_config.public_send(capability_name).to_h
          config.merge(schema_config)
        rescue ConfigurationError
          config
        end
      end
    end
  end
end
