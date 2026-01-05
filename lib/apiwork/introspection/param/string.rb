# frozen_string_literal: true

module Apiwork
  module Introspection
    module Param
      # @api public
      # String param.
      #
      # @example
      #   param.type         # => :string
      #   param.format       # => :email or nil
      #   param.min          # => 1 or nil
      #   param.max          # => 255 or nil
      #   param.scalar?      # => true
      #   param.string?      # => true
      #   param.boundable?   # => true
      #   param.formattable? # => true
      class String < Base
        # @api public
        # @return [Symbol, nil] format constraint
        #   Supported formats: :email, :uuid, :uri, :url, :ipv4, :ipv6, :hostname, :password
        def format
          @dump[:format]
        end

        # @api public
        # @return [Integer, nil] minimum string length
        def min
          @dump[:min]
        end

        # @api public
        # @return [Integer, nil] maximum string length
        def max
          @dump[:max]
        end

        # @api public
        # @return [Boolean] true for all scalar types
        def scalar?
          true
        end

        # @api public
        # @return [Boolean] whether this scalar has enum constraints
        def enum?
          @dump[:enum].present?
        end

        # @api public
        # @return [Array, Symbol, nil] inline values (Array) or ref name (Symbol)
        def enum
          @dump[:enum]
        end

        # @api public
        # @return [Boolean] whether this is a reference to a named enum
        def enum_ref?
          @dump[:enum].is_a?(Symbol)
        end

        # @api public
        # @return [Boolean] true - strings support min/max length constraints
        def boundable?
          true
        end

        # @api public
        # @return [Boolean] true - strings support format constraints
        def formattable?
          true
        end

        # @api public
        # @return [Boolean] true for string params
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
