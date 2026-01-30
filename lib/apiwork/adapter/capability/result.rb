# frozen_string_literal: true

module Apiwork
  module Adapter
    module Capability
      class Result
        attr_reader :data, :includes, :metadata, :serialize_options

        def initialize(data:, includes: nil, metadata: nil, serialize_options: nil)
          @data = data
          @metadata = metadata
          @includes = includes
          @serialize_options = serialize_options
        end
      end
    end
  end
end
