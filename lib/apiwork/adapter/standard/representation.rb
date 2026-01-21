# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      class Representation < Adapter::Representation::Base
        types Types::Errors
        resource_types Types::Resources

        attr_reader :schema_class

        def initialize(schema_class)
          super()
          @schema_class = schema_class
        end

        def serialize_resource(resource, context:, serialize_options:)
          schema_class.serialize(
            resource,
            context:,
            include: serialize_options[:include],
          )
        end

        def serialize_error(error, context:)
          error.to_h
        end
      end
    end
  end
end
