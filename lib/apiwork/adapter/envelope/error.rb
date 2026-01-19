# frozen_string_literal: true

module Apiwork
  module Adapter
    module Envelope
      class Error < Base
        def render(issues, layer, state)
          { layer:, issues: issues.map(&:to_h) }
        end
      end
    end
  end
end
