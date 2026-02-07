# frozen_string_literal: true

module Apiwork
  module Adapter
    module Serializer
      module Resource
        # @api public
        # Base class for resource serializers.
        #
        # Resource serializers handle serialization of records and collections
        # and define resource types at the contract level.
        #
        # @example
        #   class MyResourceSerializer < Serializer::Resource::Base
        #     contract_builder Builder::Contract
        #
        #     def serialize(resource, context:, serialize_options:)
        #       representation_class.serialize(resource, context:)
        #     end
        #   end
        class Base
          class << self
            def serialize(representation_class, resource, context:, serialize_options:)
              new(representation_class).serialize(resource, context:, serialize_options:)
            end

            # @api public
            # The data type resolver.
            #
            # @param block [Proc, nil] block that receives representation_class and returns type name
            # @return [Proc, nil]
            def data_type(&block)
              @data_type = block if block
              @data_type
            end

            # @api public
            # The Contract type builder class.
            #
            # @param klass [Class, nil] a Builder::Contract::Base subclass
            # @return [Class, nil]
            def contract_builder(klass = nil)
              @contract_builder = klass if klass
              @contract_builder
            end
          end

          # @api public
          # @return [Class<Representation::Base>]
          attr_reader :representation_class

          def initialize(representation_class)
            @representation_class = representation_class
          end

          def contract_types(contract_class)
            builder_class = self.class.contract_builder
            return unless builder_class

            builder_class.new(contract_class, representation_class).build
          end

          # @api public
          # Serializes a resource.
          #
          # @param resource [Object] the resource to serialize
          # @param context [Hash] serialization context
          # @param serialize_options [Hash] options (e.g., include)
          # @return [Hash]
          def serialize(resource, context:, serialize_options:)
            raise NotImplementedError
          end
        end
      end
    end
  end
end
