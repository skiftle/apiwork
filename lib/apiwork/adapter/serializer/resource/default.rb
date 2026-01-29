# frozen_string_literal: true

module Apiwork
  module Adapter
    module Serializer
      module Resource
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
