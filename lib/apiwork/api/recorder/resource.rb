# frozen_string_literal: true

module Apiwork
  module API
    class Recorder
      module Resource
        def resources(name, **options, &block)
          concern_names = options.delete(:concerns)

          capture_resource_metadata(
            name,
            singular: false,
            options: options
          )

          @pending_metadata = {}
          @resource_stack.push(name)

          concerns(*concern_names) if concern_names
          instance_eval(&block) if block

          @resource_stack.pop

          apply_resource_metadata(name)

          apply_crud_action_metadata(name)
        end

        def resource(name, **options, &block)
          concern_names = options.delete(:concerns)

          capture_resource_metadata(
            name,
            singular: true,
            options: options
          )

          @pending_metadata = {}
          @resource_stack.push(name)

          concerns(*concern_names) if concern_names
          instance_eval(&block) if block

          @resource_stack.pop

          apply_resource_metadata(name)

          apply_crud_action_metadata(name)
        end

        def with_options(options = {}, &block)
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

          crud_actions = resource[:only] || []

          crud_actions.each do |action_name|
            action_meta = @pending_metadata[:actions]&.delete(action_name) || {}

            action_meta[:summary] ||= default_crud_action_summary(action_name, name)

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
          merged_options = (@current_options || {}).merge(options)

          parent = @resource_stack.last

          contract_path = merged_options.delete(:contract)
          controller_option = merged_options.delete(:controller)

          contract = if contract_path
                       contract_path_to_class_name(contract_path)
                     else
                       infer_contract_class_name(name)
                     end

          @metadata.add_resource(
            name,
            singular: singular,
            contract: contract,
            controller: controller_option,
            parent: parent,
            **merged_options
          )
        end
      end
    end
  end
end
