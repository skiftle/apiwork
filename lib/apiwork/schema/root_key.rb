# frozen_string_literal: true

module Apiwork
  module Schema
    class RootKey
      attr_reader :plural,
                  :singular

      def initialize(singular, plural = singular.pluralize)
        @singular = singular
        @plural   = plural
      end
    end
  end
end
