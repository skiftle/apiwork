# frozen_string_literal: true

module Apiwork
  module Contract
    class Parser
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
