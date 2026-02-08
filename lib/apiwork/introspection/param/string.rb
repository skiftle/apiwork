# frozen_string_literal: true

module Apiwork
  module Introspection
    module Param
      # @api public
      # String param representing text values.
      #
      # @example Basic usage
      #   param.type         # => :string
      #   param.scalar?      # => true
      #   param.string?      # => true
      #
      # @example Constraints
      #   param.min          # => 1 or nil
      #   param.max          # => 255 or nil
      #   param.format       # => :email or nil
      #   param.boundable?   # => true
      #   param.formattable? # => true
      #
      # @example Enum
      #   if param.enum?
      #     param.enum      # => ["draft", "published"]
      #     param.enum_reference? # => false
      #   end
      class String < Base
        # @api public
        # @return [Symbol, nil]
        def format
          @dump[:format]
        end

        # @api public
        # @return [Integer, nil]
        def min
          @dump[:min]
        end

        # @api public
        # @return [Integer, nil]
        def max
          @dump[:max]
        end

        # @api public
        # @return [Boolean]
        def scalar?
          true
        end

        # @api public
        # @return [Boolean]
        def enum?
          @dump[:enum].present?
        end

        # @api public
        # @return [Array<String>, Symbol, nil]
        def enum
          @dump[:enum]
        end

        # @api public
        # @return [Boolean]
        def enum_reference?
          @dump[:enum].is_a?(Symbol)
        end

        # @api public
        # @return [Boolean]
        def boundable?
          true
        end

        # @api public
        # @return [Boolean]
        def formattable?
          true
        end

        # @api public
        # @return [Boolean]
        def string?
          true
        end

        # @api public
        # Converts this param to a hash.
        #
        # @return [Hash]
        def to_h
          result = super
          result[:enum] = enum if enum?
          result[:format] = format
          result[:max] = max
          result[:min] = min
          result
        end
      end
    end
  end
end
