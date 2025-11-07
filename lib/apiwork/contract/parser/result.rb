# frozen_string_literal: true

module Apiwork
  module Contract
    class Parser
      # Result object wrapping parsed data
      #
      # Provides a unified interface for both input and output parsing results.
      # The main data is stored in @data and can be accessed via:
      # - result.data (direction-agnostic)
      # - result[:key] (hash-like accessor)
      # - result.params (input direction only, for compatibility)
      #
      class Result
        attr_reader :data, :errors

        def initialize(data, errors)
          @data = data
          @errors = errors
        end

        def [](key)
          @data[key]
        end

        def params
          @data
        end

        def valid?
          errors.empty?
        end

        def invalid?
          errors.any?
        end
      end
    end
  end
end
