# frozen_string_literal: true

module Apiwork
  module Introspection
    # @api public
    # Param subclass for array types.
    #
    # @example
    #   param.type   # => :array
    #   param.of     # => Param for element type
    #   param.shape  # => Hash for array-of-objects
    #   param.array? # => true
    class ArrayParam < Param
      # @api public
      # @return [Param, nil] element type for arrays
      def of
        return @of if defined?(@of)

        raw = @dump[:of]
        @of = case raw
              when Hash then Param.build(raw)
              when Symbol then Param.build(type: raw)
              end
      end

      # @api public
      # @return [Hash{Symbol => Param}] nested fields for array-of-objects
      def shape
        @shape ||= (@dump[:shape] || {}).transform_values { |dump| Param.build(dump) }
      end

      # @api public
      # @return [Boolean] always true for ArrayParam
      def array?
        true
      end

      # @api public
      # @return [Hash] structured representation
      def to_h
        result = super
        result[:of] = of&.to_h
        result[:shape] = shape.transform_values(&:to_h)
        result
      end
    end
  end
end
