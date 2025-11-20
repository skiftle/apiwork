# frozen_string_literal: true

module Apiwork
  module API
    class Recorder
      # Handles recording of concern definitions
      module Concern
        # Support for concerns
        def concern(name, &block)
          # Store concern definition for later use
          @metadata.add_concern(name, block)
        end

        private

        def apply_concerns(concerns)
          return unless concerns

          concerns.each do |concern_name|
            concern_block = @metadata.concerns[concern_name]
            next unless concern_block

            # Execute concern block in current context
            instance_eval(&concern_block)
          end
        end
      end
    end
  end
end
