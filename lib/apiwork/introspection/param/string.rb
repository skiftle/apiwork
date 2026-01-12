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
      #     param.enum_ref? # => false
      #   end
      class String < Base
        # @api public
        # @return [Symbol, nil] the format constraint (:email, :uuid, :url, :datetime, :ipv4, :ipv6, :hostname, :password)
        def format
          @dump[:format]
        end

        # @api public
        # @return [Integer, nil] the minimum string length
        def min
          @dump[:min]
        end

        # @api public
        # @return [Integer, nil] the maximum string length
        def max
          @dump[:max]
        end

        # @api public
        # @return [Boolean] true if this is a scalar type
        def scalar?
          true
        end

        # @api public
        # @return [Boolean] true if this param has enum constraints
        def enum?
          @dump[:enum].present?
        end

        # @api public
        # @return [Array, Symbol, nil] enum values (Array) or reference name (Symbol)
        # @see #enum?
        def enum
          @dump[:enum]
        end

        # @api public
        # @return [Boolean] true if enum is a reference to a named enum
        def enum_ref?
          @dump[:enum].is_a?(Symbol)
        end

        # @api public
        # @return [Boolean] true if this param supports min/max constraints
        def boundable?
          true
        end

        # @api public
        # @return [Boolean] true if this param supports format constraints
        def formattable?
          true
        end

        # @api public
        # @return [Boolean] true if this is a string param
        def string?
          true
        end

        # @api public
        # @return [Hash] structured representation
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
