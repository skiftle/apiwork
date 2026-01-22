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

          # @api public
          # Declares the applier class for runtime behavior.
          #
          # @param klass [Class] an Applier::Base subclass
          # @return [Class, nil]
          def applier(klass = nil)
            @applier_class = klass if klass
            @applier_class
          end

          # @api public
          # Declares the API types class for global type registration.
          #
          # @param klass [Class] an ApiTypes::Base subclass
          # @return [Class, nil]
          def api_types_class(klass = nil)
            @api_types_class = klass if klass
            @api_types_class
          end

          # @api public
          # Declares the contract types class for per-schema type registration.
          #
          # @param klass [Class] a ContractTypes::Base subclass
          # @return [Class, nil]
          def contract_types_class(klass = nil)
            @contract_types_class = klass if klass
            @contract_types_class
          end

          # @api public
          # Declares the shape class for response shape building.
          #
          # @param klass [Class] a Shape::Base subclass
          # @return [Class, nil]
          def shape_class(klass = nil)
            @shape_class = klass if klass
            @shape_class
          end

          def api(builder_class = nil, &block)
            if builder_class
              self._api_builder_class = builder_class
            elsif block
              self._api_block = block
            end
          end

          def contract(builder_class = nil, &block)
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

          def apply_collection(applier_class = nil, &block)
            if applier_class
              self._collection_applier_class = applier_class
            elsif block
              self._collection_applier_block = block
            end
          end

          def apply_record(applier_class = nil, &block)
            if applier_class
              self._record_applier_class = applier_class
            elsif block
              self._record_applier_block = block
            end
          end

          def apply_data(applier_class = nil, &block)
            if applier_class
              self._data_applier_class = applier_class
            elsif block
              self._data_applier_block = block
            end
          end

          def wrap_api_block(callable)
            Class.new(APIBuilder::Base) do
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

        def api_types_instance
          @api_types_instance ||= self.class.api_types_class&.new(config)
        end

        def contract_types_instance
          @contract_types_instance ||= self.class.contract_types_class&.new(config)
        end

        def shape_instance
          @shape_instance ||= self.class.shape_class&.new(config)
        end

        # Registers API-wide types for this capability.
        # Delegates to api_types_instance if available.
        #
        # @api public
        # @param registrar [Object] the type registrar
        # @param capabilities [Object] adapter capabilities info
        # @return [void]
        def api_types(registrar, capabilities)
          return unless api_types_instance

          context = ApiTypesContext.new(capabilities:, registrar:)
          api_types_instance.register(context)
        end

        # Registers contract types for this capability.
        # Delegates to contract_types_instance if available.
        #
        # @api public
        # @param registrar [Object] the type registrar
        # @param schema_class [Class] the schema class
        # @param actions [Hash] the actions
        # @return [void]
        def contract_types(registrar, schema_class, actions)
          return unless contract_types_instance

          context = ContractTypesContext.new(actions:, registrar:, schema_class:)
          contract_types_instance.register(context)
        end

        # @api public
        # Returns whether this capability applies to the given document type.
        #
        # @param type [Symbol] :record or :collection
        # @return [Boolean]
        def applies_to_type?(type)
          input = self.class.input_type
          input == :any || input == type
        end

        # @api public
        # Returns the shape for this capability.
        #
        # @param context [Document::ShapeContext] the shape context
        # @return [Apiwork::Object, nil]
        def shape(context)
          return nil unless shape_instance

          object = API::Object.new
          shape_instance.build(object, context)
          object.params.empty? ? nil : object
        end

        def extract(request, schema_class)
          return {} unless self.class.applier

          context = ApplierContext.new(request:, schema_class:, action: nil)
          build_applier(context).extract
        end

        def includes(params, schema_class)
          return [] unless self.class.applier

          context = ApplierContext.new(schema_class:, action: nil, request: nil)
          context.params = params
          build_applier(context).includes
        end

        def serialize_options(params, schema_class)
          return {} unless self.class.applier

          context = ApplierContext.new(schema_class:, action: nil, request: nil)
          context.params = params
          build_applier(context).serialize_options
        end

        def apply(data, params, adapter_context)
          return Capability::ApplyResult.new(data:) unless self.class.applier

          context = ApplierContext.new(
            action: adapter_context.action,
            request: nil,
            schema_class: adapter_context.schema_class,
          )
          context.data = data
          context.params = params
          build_applier(context).apply
        end

        def applies?(action, data)
          return true if self.class.applies_to_actions.empty?
          return false unless self.class.applies_to_actions.include?(action.name)

          valid_input?(data)
        end

        private

        def build_applier(context)
          merged_config = build_merged_config(context.schema_class)
          self.class.applier.new(merged_config, context)
        end

        def build_merged_config(schema_class)
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
