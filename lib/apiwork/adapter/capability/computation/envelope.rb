# frozen_string_literal: true

module Apiwork
  module Adapter
    module Capability
      module Computation
        class Envelope
          attr_reader :json_block, :shape_block

          def initialize(&block)
            instance_eval(&block)
          end

          def json(&block)
            @json_block = block
          end

          def shape(&block)
            @shape_block = block
          end
        end
      end
    end
  end
end
