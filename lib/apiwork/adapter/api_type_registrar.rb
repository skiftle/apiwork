# frozen_string_literal: true

module Apiwork
  module Adapter
    # @api private
    class ApiTypeRegistrar
      attr_reader :api_class

      def initialize(api_class)
        @api_class = api_class
      end

      delegate :type, :enum, :union, to: :api_class
    end
  end
end
