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
        class_attribute :_computation_class
        class_attribute :_computation_block

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

          def computation(klass = nil, &block)
            if klass
              self._computation_class = klass
            elsif block
              self._computation_block = block
            end
          end

          def shape(&block)
            @shape_block = block if block
            @shape_block
          end

          def wrap_api_block(callable)
            Class.new(API::Base) do
              define_method(:build) do
                callable.arity.positive? ? callable.call(self) : instance_exec(&callable)
              end
            end
          end

          def wrap_contract_block(callable)
            Class.new(Contract::Base) do
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
          klass = self.class.api_class
          return unless klass

          klass.new(api_class, features, capability_name: self.class.capability_name, options: config).build
        end

        def contract_types(contract_class, representation_class, actions)
          klass = self.class.contract_class
          return unless klass

          klass.new(contract_class, representation_class, actions, merged_config(representation_class)).build
        end

        def shape(shape_context)
          shape_block = self.class.shape
          return nil unless shape_block

          klass = self.class.computation_class
          scope = klass&.scope
          return nil if scope && scope != shape_context.type

          target = ::Apiwork::API::Object.new
          context = ShapeContext.new(
            target:,
            options: merged_config(shape_context.representation_class),
            representation_class: shape_context.representation_class,
          )
          if shape_block.arity.positive?
            shape_block.call(context)
          else
            context.instance_exec(&shape_block)
          end
          target.params.empty? ? nil : target
        end

        def apply(data, context, document_type:)
          klass = self.class.computation_class
          return ApplyResult.new(data:) unless klass

          scope = klass.scope
          return ApplyResult.new(data:) if scope && scope != document_type

          klass.new(
            data,
            context.representation_class,
            merged_config(context.representation_class),
            context.request,
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
