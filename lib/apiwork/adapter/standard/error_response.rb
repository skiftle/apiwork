# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard < Base
      class ErrorResponse
        def self.render(issues, context)
          new(issues, context).render
        end

        def initialize(issues, context)
          @issues = issues
          @context = context
        end

        def render
          { issues: @issues.map(&:to_h) }
        end
      end
    end
  end
end
