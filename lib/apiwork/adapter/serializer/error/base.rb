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
        #     api_builder Builder::API
        #
        #     def serialize(error, context:)
        #       { errors: error.issues.map(&:to_h) }
        #     end
        #   end
        class Base
          class << self
            # @api public
            # Sets or gets the data type name for this serializer.
            #
            # @param name [Symbol, nil] the type name
            # @return [Symbol, nil]
            def data_type(name = nil)
              @data_type = name if name
              @data_type
            end

            # @api public
            # Sets or gets the API type builder class.
            #
            # @param klass [Class, nil] a Builder::API::Base subclass
            # @return [Class, nil]
            def api_builder(klass = nil)
              @api_builder = klass if klass
              @api_builder
            end
          end

          def api_types(api_class, features)
            builder_class = self.class.api_builder
            return unless builder_class

            builder_class.new(api_class, features, data_type: self.class.data_type).build
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
