# frozen_string_literal: true

module Apiwork
  module Adapter
    module Capability
      # @api public
      # Context object for response type registration.
      #
      # Passed to ResponseTypes#collection and ResponseTypes#record
      # during response type building.
      #
      # @example Adding fields to collection response
      #   def collection(context)
      #     context.response.reference :pagination, to: :offset_pagination
      #   end
      class ResponseTypesContext
        # @api public
        # @return [Object] the response builder
        attr_reader :response

        # @api public
        # @return [Class] the schema class
        attr_reader :schema_class

        def initialize(response:, schema_class:)
          @response = response
          @schema_class = schema_class
        end
      end
    end
  end
end
