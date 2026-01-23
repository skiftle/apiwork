# frozen_string_literal: true

module Apiwork
  module Adapter
    module Capability
      module Envelope
        class Context
          attr_reader :document_type, :options, :schema_class, :target

          def initialize(document_type:, options:, schema_class:, target:)
            @document_type = document_type
            @schema_class = schema_class
            @options = options
            @target = target
          end
        end
      end
    end
  end
end
