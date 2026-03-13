# frozen_string_literal: true

module Apiwork
  module Introspection
    module Param
      # @api public
      # UUID param representing universally unique identifier values.
      #
      # @example Basic usage
      #   param.type # => :uuid
      #   param.scalar? # => true
      #   param.uuid? # => true
      #
      # @example Capabilities
      #   param.formattable? # => false
      #
      # @example Enum
      #   if param.enum?
      #     param.enum # => ["550e8400-e29b-41d4-a716-446655440000"]
      #     param.enum_reference? # => false
      #   end
      class UUID < Base
        # @api public
        # The default for this param.
        #
        # @return [Object, nil]
        def default
          @dump[:default]
        end

        # @api public
        # The example for this param.
        #
        # @return [Object, nil]
        def example
          @dump[:example]
        end

        # @api public
        # Whether this param is concrete.
        #
        # @return [Boolean]
        def concrete?
          true
        end

        # @api public
        # Whether this param is scalar.
        #
        # @return [Boolean]
        def scalar?
          true
        end

        # @api public
        # Whether this param has an enum.
        #
        # @return [Boolean]
        def enum?
          @dump[:enum].present?
        end

        # @api public
        # The enum for this param.
        #
        # @return [Array<String>, Symbol, nil]
        def enum
          @dump[:enum]
        end

        # @api public
        # Whether this param is an enum reference.
        #
        # @return [Boolean]
        def enum_reference?
          @dump[:enum].is_a?(Symbol)
        end

        # @api public
        # Whether this param is a UUID.
        #
        # @return [Boolean]
        def uuid?
          true
        end

        # @api public
        # Whether this param is formattable.
        #
        # @return [Boolean]
        def formattable?
          false
        end

        # @api public
        # Converts this param to a hash.
        #
        # @return [Hash]
        def to_h
          result = super
          result[:default] = default
          result[:enum] = enum if enum?
          result[:example] = example
          result
        end
      end
    end
  end
end
