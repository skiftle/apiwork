# frozen_string_literal: true

require_relative 'validated_request'

module Apiwork
  module Controller
    module Validation
      extend ActiveSupport::Concern

      included do
        before_action :validate_input
      end

      class_methods do
        def skip_validate_input!(only: nil, except: nil)
          skip_before_action :validate_input, only:, except:
        end
      end

      def validated_request
        @validated_request ||= begin
          action_def = current_action_definition

          # Validate if action has input definition
          if action_def&.input_definition
            contract = action_def.contract_class.new
            ValidatedRequest.new(**contract.validate_input(action_name.to_sym, request))
          else
            ValidatedRequest.new(params: {}, errors: [])
          end
        end
      end

      # Input validation using contracts (before_action)
      def validate_input
        return unless validated_request.invalid?

        # Convert ValidationError objects to StructuredError format
        structured_errors = validated_request.errors.map do |error|
          StructuredError.new(
            code: error.code,
            detail: error.detail,
            path: error.path,
            **error.meta
          )
        end

        raise StructuredErrorCollection, structured_errors
      end

      private

      # Get current action definition for this action
      def current_action_definition
        @current_action_definition ||= Contract::Resolver.resolve(self.class, action_name.to_sym)
      end
    end
  end
end
