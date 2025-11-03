# frozen_string_literal: true

module Apiwork
  module API
    class Recorder
      # Handles recording of resources/resource calls
      module Resources
        # Intercept resources call (plural)
        def resources(name, **options, &block)
          # Get pending doc before processing
          doc = @pending_doc
          @pending_doc = nil

          # Capture metadata
          capture_resource_metadata(
            name,
            singular: false,
            doc: doc,
            options: options
          )

          # Handle nested block with context
          if block
            @resource_stack.push(name)
            instance_eval(&block)
            @resource_stack.pop
          end
        end

        # Intercept resource call (singular)
        def resource(name, **options, &block)
          # Get pending doc before processing
          doc = @pending_doc
          @pending_doc = nil

          capture_resource_metadata(
            name,
            singular: true,
            doc: doc,
            options: options
          )

          # Handle nested block with context
          if block
            @resource_stack.push(name)
            instance_eval(&block)
            @resource_stack.pop
          end
        end

        # Support for with_options pattern
        def with_options(options = {}, &block)
          # Store current options for merging
          old_options = @current_options
          @current_options = (@current_options || {}).merge(options)

          instance_eval(&block)

          @current_options = old_options
        end

        private

        def capture_resource_metadata(name, singular:, doc: nil, options:)
          # Merge current options (from with_options) with resource-specific options
          merged_options = (@current_options || {}).merge(options)

          # Determine parent from resource stack
          parent = @resource_stack.last

          # Infer resource class
          resource_class = infer_resource_class(name)

          # Add to metadata
          @metadata.add_resource(
            name,
            singular: singular,
            resource_class: resource_class,
            parent: parent,
            doc: doc,
            **merged_options
          )
        end
      end
    end
  end
end
