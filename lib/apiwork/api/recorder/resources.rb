# frozen_string_literal: true

module Apiwork
  module API
    class Recorder
      # Handles recording of resources/resource calls
      module Resources
        # Intercept resources call (plural)
        def resources(name, **options, &block)
          # Capture metadata
          capture_resource_metadata(
            name,
            singular: false,
            options: options
          )

          # Handle nested block with context
          return unless block

          # Clear pending metadata before block
          @pending_metadata = {}

          @resource_stack.push(name)
          instance_eval(&block)
          @resource_stack.pop

          # Apply pending resource metadata after block
          apply_resource_metadata(name)
        end

        # Intercept resource call (singular)
        def resource(name, **options, &block)
          capture_resource_metadata(
            name,
            singular: true,
            options: options
          )

          # Handle nested block with context
          return unless block

          # Clear pending metadata before block
          @pending_metadata = {}

          @resource_stack.push(name)
          instance_eval(&block)
          @resource_stack.pop

          # Apply pending resource metadata after block
          apply_resource_metadata(name)
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

        def apply_resource_metadata(name)
          resource = @metadata.find_resource(name)
          return unless resource

          resource[:metadata] = {
            summary: @pending_metadata[:summary] || default_summary(name),
            description: @pending_metadata[:description] || default_description(name),
            tags: @pending_metadata[:tags] || [name.to_s.camelize]
          }
        end

        def default_summary(name)
          name.to_s.titleize
        end

        def default_description(name)
          "Operations for managing #{name}."
        end

        def capture_resource_metadata(name, singular:, options:)
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
            **merged_options
          )
        end

        def resolve_controller_path(path)
          parts = if path.start_with?('/')
                    # Absolute path: '/admin/posts' → 'Admin::PostsController'
                    path[1..].split('/')
                  else
                    # Relative path: 'admin/posts' → 'Api::V1::Admin::PostsController'
                    @namespaces + path.split('/')
                  end

          # Camelize all parts (keep plural for controller)
          parts = parts.map { |part| part.to_s.camelize }

          # Join and append 'Controller'
          "#{parts.join('::')}Controller"
        end
      end
    end
  end
end
