# frozen_string_literal: true

module Apiwork
  module Controller
    # Wraps the validation result from contract.validate_input()
    # Provides convenient access to validation status, params, and errors
    class ValidatedRequest
      attr_reader :params, :errors

      def initialize(params:, errors:)
        @params = params
        @errors = errors
      end

      def valid?
        errors.empty?
      end

      def invalid?
        !valid?
      end
    end
  end
end
