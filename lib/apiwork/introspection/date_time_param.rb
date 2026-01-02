# frozen_string_literal: true

module Apiwork
  module Introspection
    # @api public
    # Param subclass for datetime types.
    #
    # @example
    #   param.type      # => :datetime
    #   param.datetime? # => true
    class DateTimeParam < Param
      # @api public
      # @return [Boolean] always true for DateTimeParam
      def datetime?
        true
      end
    end
  end
end
