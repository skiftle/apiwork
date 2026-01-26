# frozen_string_literal: true

module Apiwork
  module Adapter
    module Document
      # @api public
      # Context object for document shape building.
      #
      # @example Accessing context
      #   def build
      #     type_name = context.representation_class.root_key.singular.to_sym
      #     object.reference type_name
      #   end
      class ShapeContext
        # @api public
        # @return [Class] the representation class
        attr_reader :representation_class

        # @api public
        # @return [Array<Capability::Base>] adapter capabilities
        attr_reader :capabilities

        # @api public
        # @return [Symbol] the document type (:record or :collection)
        attr_reader :type

        def initialize(representation_class, capabilities, type)
          @representation_class = representation_class
          @capabilities = capabilities
          @type = type
        end

        # @api public
        # Returns capability shapes keyed by capability name.
        # Only includes capabilities that apply to the current type.
        #
        # @return [Hash{Symbol => Apiwork::Object}]
        def capability_shapes
          @capability_shapes ||= capabilities
            .each_with_object({}) do |capability, hash|
              shape = capability.shape(self)
              hash[capability.class.capability_name] = shape if shape
            end
        end
      end
    end
  end
end
