# frozen_string_literal: true

module Apiwork
  module API
    class Recorder
      module Resource
        def resources(name, **options, &block)
          concern_names = options.delete(:concerns)

          create_resource(name, singular: false, options: options)

          @pending_metadata = {}
          @resource_stack.push(name)

          concerns(*concern_names) if concern_names
          instance_eval(&block) if block

          @resource_stack.pop
        end

        def resource(name, **options, &block)
          concern_names = options.delete(:concerns)

          create_resource(name, singular: true, options: options)

          @pending_metadata = {}
          @resource_stack.push(name)

          concerns(*concern_names) if concern_names
          instance_eval(&block) if block

          @resource_stack.pop
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

        def current_resource
          return nil if @resource_stack.empty?

          @structure.find_resource(@resource_stack.last)
        end

        def create_resource(name, singular:, options:)
          merged = merged_options(options)

          parent_name = @resource_stack.last
          parent_resource = parent_name ? @structure.find_resource(parent_name) : nil

          contract_path = merged.delete(:contract)
          controller_option = merged.delete(:controller)

          contract = if contract_path
                       contract_path_to_class_name(contract_path)
                     else
                       infer_contract_class_name(name)
                     end

          resource = Structure::Resource.new(
            name: name,
            singular: singular,
            contract: contract,
            controller: controller_option,
            parent: parent_name,
            **merged
          )

          if parent_resource
            parent_resource.add_resource(resource)
          else
            @structure.add_resource(resource)
          end
        end
      end
    end
  end
end
