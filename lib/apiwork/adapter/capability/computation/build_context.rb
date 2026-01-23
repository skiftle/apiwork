# frozen_string_literal: true

module Apiwork
  module Adapter
    module Capability
      module Computation
        class BuildContext
          attr_reader :additions, :json, :options, :schema_class

          def initialize(additions:, json:, options:, schema_class:)
            @additions = additions
            @json = json
            @options = options
            @schema_class = schema_class
          end
        end
      end
    end
  end
end
