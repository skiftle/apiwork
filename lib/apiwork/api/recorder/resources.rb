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

          # Extract override options (Rails-style paths)
          contract_path = merged_options[:contract]
          controller_path = merged_options[:controller]

          # Always infer resource class from name (no override)
          resource_class = infer_resource_class(name)

          # Resolve contract: use explicit path or infer from name
          contract_class_name = if contract_path
            resolve_contract_path(contract_path)
          else
            infer_contract_class(name)&.name
          end

          # Resolve controller: use explicit path or infer from name
          controller_class_name = if controller_path
            # Rails handles controller: path natively, convert to class name for metadata
            resolve_controller_path(controller_path)
          else
            infer_controller_class(name)&.name
          end

          # Add to metadata
          @metadata.add_resource(
            name,
            singular: singular,
            schema_class: resource_class,
            controller_class_name: controller_class_name,
            contract_class_name: contract_class_name,
            parent: parent,
            doc: doc,
            **merged_options
          )
        end

        # Resolve Rails controller path to full class name
        # @param path [String] Controller path (e.g., 'admin/posts' or '/admin/posts')
        # @return [String] Full controller class name
        def resolve_controller_path(path)
          if path.start_with?('/')
            # Absolute path: '/admin/posts' → 'Admin::PostsController'
            parts = path[1..].split('/')
          else
            # Relative path: 'admin/posts' → 'Api::V1::Admin::PostsController'
            parts = @namespaces + path.split('/')
          end

          # Camelize all parts (keep plural for controller)
          parts = parts.map { |part| part.to_s.camelize }

          # Join and append 'Controller'
          parts.join('::') + 'Controller'
        end
      end
    end
  end
end
