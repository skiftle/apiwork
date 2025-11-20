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
          if block
            # Clear pending metadata before block
            @pending_metadata = {}

            @resource_stack.push(name)
            instance_eval(&block)
            @resource_stack.pop
          end

          # Apply pending resource metadata after block (or immediately if no block)
          apply_resource_metadata(name)

          # Generate and store CRUD action metadata
          apply_crud_action_metadata(name)
        end

        # Intercept resource call (singular)
        def resource(name, **options, &block)
          capture_resource_metadata(
            name,
            singular: true,
            options: options
          )

          # Handle nested block with context
          if block
            # Clear pending metadata before block
            @pending_metadata = {}

            @resource_stack.push(name)
            instance_eval(&block)
            @resource_stack.pop
          end

          # Apply pending resource metadata after block (or immediately if no block)
          apply_resource_metadata(name)

          # Generate and store CRUD action metadata
          apply_crud_action_metadata(name)
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

        def apply_crud_action_metadata(name)
          resource = @metadata.find_resource(name)
          return unless resource

          # Get CRUD actions list for this resource
          crud_actions = resource[:only] || []

          # Generate metadata for each CRUD action
          crud_actions.each do |action_name|
            action_meta = @pending_metadata[:actions]&.delete(action_name) || {}

            # Apply default summary if not provided
            action_meta[:summary] ||= default_crud_action_summary(action_name, name)

            # Add CRUD action with metadata to metadata store
            @metadata.add_crud_action(
              name,
              action_name,
              method: crud_action_method(action_name),
              metadata: action_meta
            )
          end
        end

        def default_crud_action_summary(action, resource_name)
          resource_singular = resource_name.to_s.singularize
          resource_plural = resource_name.to_s

          case action.to_sym
          when :index then "List #{resource_plural}"
          when :show then "Get #{resource_singular}"
          when :create then "Create #{resource_singular}"
          when :update then "Update #{resource_singular}"
          when :destroy then "Delete #{resource_singular}"
          end
        end

        def crud_action_method(action_name)
          case action_name.to_sym
          when :index then :get
          when :show then :get
          when :create then :post
          when :update then :patch
          when :destroy then :delete
          else :get
          end
        end

        def capture_resource_metadata(name, singular:, options:)
          # Merge current options (from with_options) with resource-specific options
          merged_options = (@current_options || {}).merge(options)

          # Determine parent from resource stack
          parent = @resource_stack.last

          # Extract override options (Rails-style paths)
          contract_path = merged_options[:contract]
          controller_option = merged_options[:controller]

          # Always infer resource class from name (no override)
          resource_class = infer_resource_class(name)

          # Resolve contract: use explicit path or infer from name
          contract_class = if contract_path
                             constantize_contract_path(contract_path)
                           else
                             infer_contract_class(name)
                           end

          # Add to metadata
          @metadata.add_resource(
            name,
            singular: singular,
            schema_class: resource_class,
            controller: controller_option,
            contract_class: contract_class,
            parent: parent,
            **merged_options
          )
        end
      end
    end
  end
end
