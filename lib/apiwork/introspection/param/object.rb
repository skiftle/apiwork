# frozen_string_literal: true

module Apiwork
  module Introspection
    module Param
      # @api public
      # Object param representing structured data with named fields.
      #
      # @example Basic usage
      #   param.type      # => :object
      #   param.object?   # => true
      #   param.scalar?   # => false
      #
      # @example Fields
      #   param.shape     # => { name: Param, email: Param }
      #
      # @example Partial objects (for updates)
      #   param.partial?  # => true if all fields are optional
      class Object < Base
        # @api public
        # The shape for this param.
        #
        # @return [Hash{Symbol => Param::Base}]
        def shape
          return @shape if defined?(@shape)

          @shape = @dump[:shape]&.transform_values { |dump| Param.build(dump) } || {}
        end

        # @api public
        # Whether this param uses partial serialization.
        #
        # @return [Boolean]
        def partial?
          @dump[:partial]
        end

        # @api public
        # @return [Boolean]
        def object?
          true
        end

        # @api public
        # Converts this param to a hash.
        #
        # @return [Hash]
        def to_h
          result = super
          result[:partial] = partial?
          result[:shape] = shape.transform_values(&:to_h)
          result
        end
      end
    end
  end
end
