# frozen_string_literal: true

module Apiwork
  module Contract
    class Parser
      # Validation logic for Parser
      #
      # Handles validation and error handling:
      # - Wraps Definition.validate for consistency
      # - Handles validation errors based on direction (input vs output)
      # - Input: returns empty data on error (invalid input should not be processed)
      # - Output: returns original data on error (allows debugging without breaking API)
      #
      module Validation
        extend ActiveSupport::Concern

        private

        # Validate data using definition
        def validate(data)
          # For OUTPUT: skip validation if no definition or empty params
          if @direction == :output
            return { params: data, issues: [] } unless definition
            return { params: data, issues: [] } if definition.params.empty?
          end

          # For INPUT: only skip if no definition AND no data
          return { params: {}, issues: [] } if (@direction == :input) && !(definition || data.present?)

          return { params: data, issues: [] } unless definition

          definition.validate(data) || { params: data, issues: [] }
        end

        # Handle validation errors based on direction
        #
        # Input: Return empty data (invalid input should not be processed)
        # Output: Return original data (validation failure indicates a bug in response building,
        #         but we still return the response to avoid breaking the API)
        def handle_validation_errors(original_data, errors)
          case @direction
          when :input
            # Input: Never return invalid params
            build_result({}, errors)
          when :output
            # Output: Return response even if invalid (validation serves as warning)
            # This allows debugging of response structure issues without breaking API
            build_result(original_data, errors)
          end
        end
      end
    end
  end
end
