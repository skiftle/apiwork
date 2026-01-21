# frozen_string_literal: true

module Apiwork
  module Adapter
    module Capability
      class Base
        include Configurable

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
          # Declares the response types class for response type registration.
          #
          # @param klass [Class] a ResponseTypes::Base subclass
          # @return [Class, nil]
          def response_types_class(klass = nil)
            @response_types_class = klass if klass
            @response_types_class
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

        def response_types_instance
          @response_types_instance ||= self.class.response_types_class&.new(config)
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

        # Adds fields to the collection response type.
        # Delegates to response_types_instance if available.
        #
        # @api public
        # @param response [Object] the response builder
        # @param schema_class [Class] the schema class
        # @return [void]
        def collection_response_types(response, schema_class)
          return unless response_types_instance

          context = ResponseTypesContext.new(response:, schema_class:)
          response_types_instance.collection(context)
        end

        # Adds fields to the record response type.
        # Delegates to response_types_instance if available.
        #
        # @api public
        # @param response [Object] the response builder
        # @param schema_class [Class] the schema class
        # @return [void]
        def record_response_types(response, schema_class)
          return unless response_types_instance

          context = ResponseTypesContext.new(response:, schema_class:)
          response_types_instance.record(context)
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

        def apply(data, metadata, params, adapter_context)
          return data unless self.class.applier

          context = ApplierContext.new(
            action: adapter_context.action,
            request: nil,
            schema_class: adapter_context.schema_class,
          )
          context.data = data
          context.metadata = metadata
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
