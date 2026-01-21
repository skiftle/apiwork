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
        end

        attr_reader :config

        def initialize(config = {})
          merged = self.class.default_options.deep_merge(config)
          @config = Configuration.new(self.class, merged)
        end

        # Registers API-wide types for this capability.
        #
        # @api public
        # @param registrar [Object] the type registrar
        # @param capabilities [Object] adapter capabilities info
        # @return [void]
        def api_types(registrar, capabilities); end

        # Registers contract types for this capability.
        #
        # @api public
        # @param registrar [Object] the type registrar
        # @param schema_class [Class] the schema class
        # @param actions [Hash] the actions
        # @return [void]
        def contract_types(registrar, schema_class, actions); end

        # Adds fields to the collection response type.
        #
        # @api public
        # @param response [Object] the response builder
        # @param schema_class [Class] the schema class
        # @return [void]
        def collection_response_types(response, schema_class); end

        # Adds fields to the record response type.
        #
        # @api public
        # @param response [Object] the response builder
        # @param schema_class [Class] the schema class
        # @return [void]
        def record_response_types(response, schema_class); end

        def extract(request, schema_class)
          {}
        end

        def includes(params, schema_class)
          []
        end

        def serialize_options(params, schema_class)
          {}
        end

        def apply(data, metadata, params, context)
          data
        end

        def applies?(action, data)
          return true if self.class.applies_to_actions.empty?
          return false unless self.class.applies_to_actions.include?(action.name)

          valid_input?(data)
        end

        private

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
