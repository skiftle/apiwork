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
        #     contract MyContract
        #
        #     def serialize(resource, context:, serialize_options:)
        #       representation_class.serialize(resource, context:)
        #     end
        #   end
        class Base
          class << self
            # @api public
            # Sets the Contract type builder class.
            #
            # @param klass [Class] a Serializer::Contract::Base subclass
            # @return [void]
            def contract(klass)
              @contract_builder = klass
            end

            attr_reader :contract_builder
          end

          # @api public
          # @return [Class] the representation class
          attr_reader :representation_class

          def initialize(representation_class)
            @representation_class = representation_class
          end

          def contract_types(contract_class)
            builder = self.class.contract_builder
            return unless builder

            builder.new(contract_class, representation_class).build
          end

          # @api public
          # Serializes a resource.
          #
          # @param resource [Object] the resource to serialize
          # @param context [Hash] serialization context
          # @param serialize_options [Hash] options (e.g., include)
          # @return [Hash] the serialized resource
          def serialize(resource, context:, serialize_options:)
            raise NotImplementedError
          end
        end
      end
    end
  end
end
