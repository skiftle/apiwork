# frozen_string_literal: true

module Apiwork
  module Adapter
    module Capability
      class ApplyResult
        attr_reader :additions, :data, :includes, :serialize_options

        def initialize(additions: {}, data:, includes: nil, serialize_options: nil)
          @data = data
          @additions = additions
          @includes = includes
          @serialize_options = serialize_options
        end
      end
    end
  end
end
