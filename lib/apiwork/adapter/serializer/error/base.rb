# frozen_string_literal: true

module Apiwork
  module Adapter
    module Serializer
      module Error
        # @api public
        # Base class for error serializers.
        #
        # Error serializers handle serialization of errors and define
        # error-related types at the API level.
        #
        # @example
        #   class MyErrorSerializer < Serializer::Error::Base
        #     api MyAPI
        #
        #     def serialize(error, context:)
        #       { errors: error.issues.map(&:to_h) }
        #     end
        #   end
        class Base
          class << self
            # @api public
            # Sets the API type builder class.
            #
            # @param klass [Class] a Serializer::API::Base subclass
            # @return [void]
            def api(klass)
              @api_builder = klass
            end

            attr_reader :api_builder
          end

          def api_types(api_class, features)
            builder = self.class.api_builder
            return unless builder

            builder.new(api_class, features).build
          end

          # @api public
          # Serializes an error.
          #
          # @param error [Error] the error to serialize
          # @param context [Hash] serialization context
          # @return [Hash] the serialized error
          def serialize(error, context:)
            raise NotImplementedError
          end
        end
      end
    end
  end
end
