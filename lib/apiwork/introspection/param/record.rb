# frozen_string_literal: true

module Apiwork
  module Introspection
    module Param
      # @api public
      # Record param representing key-value maps with typed values.
      #
      # @example Basic usage
      #   param.type # => :record
      #   param.record? # => true
      #   param.scalar? # => false
      #
      # @example Value type
      #   param.of # => Param (value type) or nil
      class Record < Base
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
        # The value type for this record.
        #
        # @return [Param::Base, nil]
        def of
          @of ||= @dump[:of] ? Param.build(@dump[:of]) : nil
        end

        # @api public
        # Whether this param is a record.
        #
        # @return [Boolean]
        def record?
          true
        end

        # @api public
        # Whether this param is concrete.
        #
        # @return [Boolean]
        def concrete?
          true
        end

        # @api public
        # Converts this param to a hash.
        #
        # @return [Hash]
        def to_h
          result = super
          result[:default] = default
          result[:example] = example
          result[:of] = of&.to_h
          result
        end
      end
    end
  end
end
