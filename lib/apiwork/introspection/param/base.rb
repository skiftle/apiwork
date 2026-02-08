# frozen_string_literal: true

module Apiwork
  module Introspection
    module Param
      class Base
        def initialize(dump)
          @dump = dump
        end

        # @api public
        # @return [Symbol]
        def type
          @dump[:type]
        end

        # @api public
        # @return [Boolean]
        def nullable?
          @dump[:nullable]
        end

        # @api public
        # @return [Boolean]
        def optional?
          @dump[:optional]
        end

        # @api public
        # @return [Boolean]
        def deprecated?
          @dump[:deprecated]
        end

        # @api public
        # @return [String, nil]
        def description
          @dump[:description]
        end

        # @api public
        # @return [Object, nil]
        def example
          @dump[:example]
        end

        # @api public
        # @return [Object, nil]
        def default
          @dump[:default]
        end

        # @api public
        # @return [Boolean]
        def default?
          @dump.key?(:default)
        end

        # @api public
        # @return [String, nil]
        def tag
          @dump[:tag]
        end

        # @api public
        # @return [Boolean]
        def scalar?
          false
        end

        # @api public
        # @return [Boolean]
        def array?
          false
        end

        # @api public
        # @return [Boolean]
        def object?
          false
        end

        # @api public
        # @return [Boolean]
        def union?
          false
        end

        # @api public
        # @return [Boolean]
        def literal?
          false
        end

        # @api public
        # @return [Boolean]
        def numeric?
          false
        end

        # @api public
        # @return [Boolean]
        def boundable?
          false
        end

        # @api public
        # @return [Boolean]
        def string?
          false
        end

        # @api public
        # @return [Boolean]
        def integer?
          false
        end

        # @api public
        # @return [Boolean]
        def number?
          false
        end

        # @api public
        # @return [Boolean]
        def decimal?
          false
        end

        # @api public
        # @return [Boolean]
        def boolean?
          false
        end

        # @api public
        # @return [Boolean]
        def datetime?
          false
        end

        # @api public
        # @return [Boolean]
        def date?
          false
        end

        # @api public
        # @return [Boolean]
        def time?
          false
        end

        # @api public
        # @return [Boolean]
        def uuid?
          false
        end

        # @api public
        # @return [Boolean]
        def binary?
          false
        end

        # @api public
        # @return [Boolean]
        def unknown?
          false
        end

        # @api public
        # @return [Boolean]
        def reference?
          false
        end

        # @api public
        # @return [Boolean]
        def enum?
          false
        end

        # @api public
        # @return [Boolean]
        def enum_reference?
          false
        end

        # @api public
        # @return [Boolean]
        def formattable?
          false
        end

        # @api public
        # @return [Boolean]
        def partial?
          false
        end

        # @api public
        # Converts this param to a hash.
        #
        # @return [Hash]
        def to_h
          {
            default: default,
            deprecated: deprecated?,
            description: description,
            example: example,
            nullable: nullable?,
            optional: optional?,
            type: type,
          }
        end
      end
    end
  end
end
