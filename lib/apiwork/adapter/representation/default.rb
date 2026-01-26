# frozen_string_literal: true

module Apiwork
  module Adapter
    module Representation
      class Default < Base
        types Types::Errors
        resource_types Types::Resources

        attr_reader :representation_class

        def initialize(representation_class)
          super()
          @representation_class = representation_class
        end

        def serialize_resource(resource, context:, serialize_options:)
          representation_class.serialize(
            resource,
            context:,
            include: serialize_options[:include],
          )
        end

        def serialize_error(error, context:)
          {
            issues: error.issues.map(&:to_h),
            layer: error.layer,
          }
        end
      end
    end
  end
end
