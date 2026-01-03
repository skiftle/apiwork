# frozen_string_literal: true

module Apiwork
  module Introspection
    module Param
      class Scalar
        class Enum
          # @api public
          # Inline enum param.
          #
          # @example
          #   param.type    # => :string (base type)
          #   param.enum    # => ["draft", "published", "archived"]
          #   param.scalar? # => true
          #   param.enum?   # => true
          #   param.inline? # => true
          class Inline < Enum
            # @api public
            # @return [Boolean] always true for Inline enums
            def inline?
              true
            end
          end
        end
      end
    end
  end
end
