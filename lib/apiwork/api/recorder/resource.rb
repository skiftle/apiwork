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
          @current_options = merged_options(options)

          instance_eval(&block)

          @current_options = old_options
        end

        private

        def merged_options(options = {})
          (@current_options || {}).merge(options)
        end

        def apply_resource_metadata(name)
          resource = @metadata.find_resource(name)
          return unless resource

          resource[:metadata] = {
            summary: @pending_metadata[:summary],
            description: @pending_metadata[:description],
            tags: @pending_metadata[:tags]
          }.compact
        end

        def apply_crud_action_metadata(name)
          resource = @metadata.find_resource(name)
          return unless resource

          crud_actions = resource[:only] || []

          crud_actions.each do |action_name|
            @metadata.add_crud_action(
              name,
              action_name,
              method: crud_action_method(action_name)
            )
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
          merged = merged_options(options)

          parent = @resource_stack.last

          contract_path = merged.delete(:contract)
          controller_option = merged.delete(:controller)

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
            **merged
          )
        end
      end
    end
  end
end
