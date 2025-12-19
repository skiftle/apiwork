# frozen_string_literal: true

module Apiwork
  module Schema
    # @api private
    class RootKey
      attr_reader :plural,
                  :singular

      def initialize(singular, plural = singular.pluralize)
        @singular = singular
        @plural   = plural
      end

      def to_s
        singular
      end
    end
  end
end
