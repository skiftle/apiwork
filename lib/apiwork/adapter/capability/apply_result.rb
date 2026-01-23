# frozen_string_literal: true

module Apiwork
  module Adapter
    module Capability
      class ApplyResult
        attr_reader :data, :document, :includes, :serialize_options

        def initialize(data:, document: nil, includes: nil, serialize_options: nil)
          @data = data
          @document = document
          @includes = includes
          @serialize_options = serialize_options
        end
      end
    end
  end
end
