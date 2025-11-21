# frozen_string_literal: true

module Apiwork
  module API
    class Recorder
      module Concern
        def concern(name, &block)
          @metadata.add_concern(name, block)
        end

        private

        def apply_concerns(concerns)
          return unless concerns

          concerns.each do |concern_name|
            concern_block = @metadata.concerns[concern_name]
            next unless concern_block

            instance_eval(&concern_block)
          end
        end
      end
    end
  end
end
