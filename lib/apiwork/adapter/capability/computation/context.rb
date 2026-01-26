# frozen_string_literal: true

module Apiwork
  module Adapter
    module Capability
      module Computation
        class Context
          attr_reader :data, :options, :representation_class, :request

          def initialize(data:, options:, representation_class:, request:)
            @data = data
            @request = request
            @options = options
            @representation_class = representation_class
          end
        end
      end
    end
  end
end
