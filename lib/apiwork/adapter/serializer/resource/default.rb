# frozen_string_literal: true

module Apiwork
  module Adapter
    module Serializer
      module Resource
        # @api public
        # Default resource serializer.
        #
        # Delegates serialization to the representation class using its root key as data type.
        #
        # @example Configuration
        #   class MyAdapter < Adapter::Base
        #     serializer Serializer::Resource::Default
        #   end
        #
        # @example Output
        #   {
        #     "id": 1,
        #     "number": "INV-001",
        #     "customer": { "id": 5, "name": "Acme" }
        #   }
        class Default < Base
          data_type { |representation_class| representation_class.root_key.singular.to_sym }

          contract_builder ContractBuilder

          def serialize(resource, context:, serialize_options:)
            representation_class.serialize(
              resource,
              context:,
              include: serialize_options[:include],
            )
          end
        end
      end
    end
  end
end
