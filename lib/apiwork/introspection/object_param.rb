# frozen_string_literal: true

module Apiwork
  module Introspection
    # @api public
    # Param subclass for object types.
    #
    # @example
    #   param.type      # => :object
    #   param.shape     # => { name: Param, email: Param }
    #   param.partial?  # => true for update payloads
    #   param.object?   # => true
    class ObjectParam < Param
      # @api public
      # @return [Hash{Symbol => Param}] nested fields
      def shape
        @shape ||= (@dump[:shape] || {}).transform_values { |dump| Param.build(dump) }
      end

      # @api public
      # @return [Boolean] whether this object is partial (for update payloads)
      def partial?
        @dump[:partial] == true
      end

      # @api public
      # @return [Boolean] always true for ObjectParam
      def object?
        true
      end

      # @api public
      # @return [Hash] structured representation
      def to_h
        result = super
        result[:partial] = partial?
        result[:shape] = shape.transform_values(&:to_h)
        result
      end
    end
  end
end
