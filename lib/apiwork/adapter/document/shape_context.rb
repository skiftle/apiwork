# frozen_string_literal: true

module Apiwork
  module Adapter
    module Document
      # @api public
      # Context object for document shape building.
      #
      # @example Accessing context
      #   def build
      #     type_name = context.schema_class.root_key.singular.to_sym
      #     builder.reference type_name
      #   end
      class ShapeContext
        # @api public
        # @return [Class] the schema class
        attr_reader :schema_class

        # @api public
        # @return [Array<Capability::Base>] adapter capabilities
        attr_reader :capabilities

        def initialize(schema_class, capabilities)
          @schema_class = schema_class
          @capabilities = capabilities
        end
      end
    end
  end
end
