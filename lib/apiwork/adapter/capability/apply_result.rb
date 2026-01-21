# frozen_string_literal: true

module Apiwork
  module Adapter
    module Capability
      class ApplyResult
        attr_reader :additions, :data

        def initialize(additions: {}, data:)
          @data = data
          @additions = additions
        end
      end
    end
  end
end
