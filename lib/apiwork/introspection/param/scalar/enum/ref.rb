# frozen_string_literal: true

module Apiwork
  module Introspection
    module Param
      class Scalar
        class Enum
          # @api public
          # Enum reference param.
          #
          # @example
          #   param.type    # => :string (base type)
          #   param.enum    # => :status (enum name symbol)
          #   param.scalar? # => true
          #   param.enum?   # => true
          #   param.ref?    # => true
          class Ref < Enum
            # @api public
            # @return [Boolean] always true for Ref enums
            def ref?
              true
            end
          end
        end
      end
    end
  end
end
