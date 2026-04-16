# frozen_string_literal: true

module Apiwork
  module Introspection
    module Param
      # @api public
      # Time param representing time-of-day values.
      #
      # @example Basic usage
      #   param.type # => :time
      #   param.scalar? # => true
      #   param.time? # => true
      #
      # @example Capabilities
      #   param.formattable? # => false
      #
      # @example Enum
      #   if param.enum?
      #     param.enum # => ["09:00", "17:00"]
      #     param.enum_reference? # => false
      #   end
      class Time < Base
        # @api public
        # The default for this param.
        #
        # Returns `nil` for both "no default" and "default is explicitly `nil`".
        # Use {#default?} to distinguish these cases.
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
        # Whether this param is a time.
        #
        # @return [Boolean]
        def time?
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
