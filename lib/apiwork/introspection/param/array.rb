# frozen_string_literal: true

module Apiwork
  module Introspection
    module Param
      # @api public
      # Array param.
      #
      # @example
      #   param.type       # => :array
      #   param.of         # => Param for element type
      #   param.shape      # => Hash for array-of-objects
      #   param.min        # => 1 (minimum array length)
      #   param.max        # => 10 (maximum array length)
      #   param.array?     # => true
      #   param.boundable? # => true
      class Array < Base
        # @api public
        # @return [Param::Base, nil] element type for arrays
        def of
          return @of if defined?(@of)

          raw = @dump[:of]
          @of = case raw
                when Hash then Param.build(raw)
                when Symbol then Param.build(type: raw)
                end
        end

        # @api public
        # @return [Hash{Symbol => Param::Base}] nested fields for array-of-objects
        def shape
          @shape ||= (@dump[:shape] || {}).transform_values { |dump| Param.build(dump) }
        end

        # @api public
        # @return [Integer, nil] minimum array length
        def min
          @dump[:min]
        end

        # @api public
        # @return [Integer, nil] maximum array length
        def max
          @dump[:max]
        end

        # @api public
        # @return [Boolean] always true for Array
        def array?
          true
        end

        # @api public
        # @return [Boolean] true - arrays support min/max length constraints
        def boundable?
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
end
