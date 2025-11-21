# frozen_string_literal: true

module Apiwork
  module Contract
    class Parser
      module Validation
        extend ActiveSupport::Concern

        private

        def validate(data)
          if @direction == :output
            return { params: data, issues: [] } unless definition
            return { params: data, issues: [] } if definition.params.empty?
          end

          return { params: {}, issues: [] } if (@direction == :input) && definition.nil? && data.blank?

          return { params: data, issues: [] } unless definition

          definition.validate(data) || { params: data, issues: [] }
        end

        def handle_validation_errors(original_data, errors)
          case @direction
          when :input
            build_result({}, errors)
          when :output
            build_result(original_data, errors)
          end
        end
      end
    end
  end
end
