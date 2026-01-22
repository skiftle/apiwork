# frozen_string_literal: true

module Apiwork
  module Adapter
    module Capability
      class Base
        include Configurable

        class_attribute :_api_builder_class
        class_attribute :_api_block
        class_attribute :_contract_builder_class
        class_attribute :_contract_block
        class_attribute :_response_shape_builder_class
        class_attribute :_response_shape_block
        class_attribute :_collection_applier_class
        class_attribute :_collection_applier_block
        class_attribute :_record_applier_class
        class_attribute :_record_applier_block
        class_attribute :_data_applier_class
        class_attribute :_data_applier_block

        class << self
          def capability_name(value = nil)
            @capability_name = value.to_sym if value
            @capability_name
          end

          def applies_to(*action_types)
            @applies_to = action_types.map(&:to_sym)
          end

          def applies_to_actions
            @applies_to || []
          end

          def input(type)
            @input_type = type
          end

          def input_type
            @input_type || :any
          end

          def request_transformer(klass, post: false)
            @request_transformers ||= []
            @request_transformers << { klass:, post: }
          end

          def request_transformers
            @request_transformers || []
          end

          def api_builder(builder_class = nil, &block)
            if builder_class
              self._api_builder_class = builder_class
            elsif block
              self._api_block = block
            end
          end

          def contract_builder(builder_class = nil, &block)
            if builder_class
              self._contract_builder_class = builder_class
            elsif block
              self._contract_block = block
            end
          end

          def response_shape(builder_class = nil, &block)
            if builder_class
              self._response_shape_builder_class = builder_class
            elsif block
              self._response_shape_block = block
            end
          end

          def collection_applier(applier_class = nil, &block)
            if applier_class
              self._collection_applier_class = applier_class
            elsif block
              self._collection_applier_block = block
            end
          end

          def record_applier(applier_class = nil, &block)
            if applier_class
              self._record_applier_class = applier_class
            elsif block
              self._record_applier_block = block
            end
          end

          def data_applier(applier_class = nil, &block)
            if applier_class
              self._data_applier_class = applier_class
            elsif block
              self._data_applier_block = block
            end
          end

          def wrap_api_block(callable)
            Class.new(ApiBuilder::Base) do
              define_method(:build) do
                instance_exec(&callable)
              end
            end
          end

          def wrap_contract_block(callable)
            Class.new(ContractBuilder::Base) do
              define_method(:build) do
                instance_exec(&callable)
              end
            end
          end

          def wrap_response_shape_block(callable)
            Class.new(ResponseShapeBuilder::Base) do
              define_method(:build) do
                instance_exec(&callable)
              end
            end
          end

          def wrap_collection_applier_block(callable)
            Class.new(CollectionApplier::Base) do
              define_method(:apply) do
                instance_exec(&callable)
              end
            end
          end

          def wrap_record_applier_block(callable)
            Class.new(RecordApplier::Base) do
              define_method(:apply) do
                instance_exec(&callable)
              end
            end
          end

          def wrap_data_applier_block(callable)
            Class.new(DataApplier::Base) do
              define_method(:apply) do
                instance_exec(&callable)
              end
            end
          end

          def api_builder_class
            return _api_builder_class if _api_builder_class
            return wrap_api_block(_api_block) if _api_block

            nil
          end

          def contract_builder_class
            return _contract_builder_class if _contract_builder_class
            return wrap_contract_block(_contract_block) if _contract_block

            nil
          end

          def response_shape_builder_class
            return _response_shape_builder_class if _response_shape_builder_class
            return wrap_response_shape_block(_response_shape_block) if _response_shape_block

            nil
          end

          def collection_applier_class
            return _collection_applier_class if _collection_applier_class
            return wrap_collection_applier_block(_collection_applier_block) if _collection_applier_block

            nil
          end

          def record_applier_class
            return _record_applier_class if _record_applier_class
            return wrap_record_applier_block(_record_applier_block) if _record_applier_block

            nil
          end

          def data_applier_class
            return _data_applier_class if _data_applier_class
            return wrap_data_applier_block(_data_applier_block) if _data_applier_block

            nil
          end
        end

        attr_reader :config

        def initialize(config = {})
          merged = self.class.default_options.deep_merge(config)
          @config = Configuration.new(self.class, merged)
        end

        def api_types(registrar, capabilities)
          builder_class = self.class.api_builder_class
          return unless builder_class

          context = ApiBuilder::Context.new(
            capabilities:,
            capability_name: self.class.capability_name,
            options: config,
            registrar:,
          )
          builder_class.new(context).build
        end

        def contract_types(registrar, schema_class, actions)
          builder_class = self.class.contract_builder_class
          return unless builder_class

          context = ContractBuilder::Context.new(
            actions:,
            registrar:,
            schema_class:,
            options: merged_config(schema_class),
          )
          builder_class.new(context).build
        end

        def applies_to_type?(type)
          input = self.class.input_type
          input == :any || input == type
        end

        def shape(shape_context)
          builder_class = self.class.response_shape_builder_class
          return nil unless builder_class

          target = API::Object.new
          context = ResponseShapeBuilder::Context.new(
            target:,
            options: merged_config(shape_context.schema_class),
            schema_class: shape_context.schema_class,
          )
          builder_class.new(context).build
          target.params.empty? ? nil : target
        end

        def apply(data, adapter_context)
          applier_class = resolve_applier_class(data)

          if applier_class
            context = build_applier_context(data, adapter_context)
            applier_class.new(context).apply
          else
            ApplyResult.new(data:)
          end
        end

        def applies?(action, data)
          return true if self.class.applies_to_actions.empty?
          return false unless self.class.applies_to_actions.include?(action.name)

          valid_input?(data)
        end

        private

        def resolve_applier_class(data)
          case self.class.input_type
          when :collection
            self.class.collection_applier_class
          when :record
            self.class.record_applier_class
          else
            self.class.data_applier_class || self.class.collection_applier_class || self.class.record_applier_class
          end
        end

        def build_applier_context(data, adapter_context)
          options = merged_config(adapter_context.schema_class)
          request = adapter_context.request
          schema_class = adapter_context.schema_class

          case self.class.input_type
          when :collection
            CollectionApplier::Context.new(options:, request:, schema_class:, collection: data)
          when :record
            RecordApplier::Context.new(options:, request:, schema_class:, record: data)
          else
            DataApplier::Context.new(data:, options:, request:, schema_class:)
          end
        end

        def merged_config(schema_class)
          capability_name = self.class.capability_name
          return config unless capability_name

          schema_config = schema_class.adapter_config.public_send(capability_name).to_h
          config.merge(schema_config)
        rescue ConfigurationError
          config
        end

        def valid_input?(data)
          case self.class.input_type
          when :collection
            data.is_a?(ActiveRecord::Relation)
          when :record
            data.is_a?(ActiveRecord::Base)
          else
            true
          end
        end
      end
    end
  end
end
