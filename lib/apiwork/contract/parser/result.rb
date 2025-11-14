# frozen_string_literal: true

module Apiwork
  module Contract
    class Parser
      class Result
        attr_reader :data, :issues

        def initialize(data, issues)
          @data = data
          @issues = issues
        end

        def [](key)
          @data[key]
        end

        def params
          @data
        end

        def valid?
          issues.empty?
        end

        def invalid?
          issues.any?
        end
      end
    end
  end
end
