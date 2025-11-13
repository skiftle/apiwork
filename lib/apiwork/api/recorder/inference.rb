# frozen_string_literal: true

module Apiwork
  module API
    class Recorder
      # Handles inferring resource/contract/controller class names
      module Inference
        private

        # Auto-discover the Schema class based on namespaces and resource name
        def infer_resource_class(name)
          # Build class name from namespaces array: [:api, :v1] -> 'Api::V1::AccountSchema'
          resource_name = name.to_s.singularize.camelize
          class_name = "#{namespaces_string}::#{resource_name}Schema"

          class_name.constantize
        rescue NameError
          nil
        end

        # Auto-discover the Contract class based on namespaces and resource name
        def infer_contract_class(name)
          # Build class name from namespaces array: [:api, :v1] + :posts -> 'Api::V1::PostContract'
          contract_name = name.to_s.singularize.camelize
          class_name = "#{namespaces_string}::#{contract_name}Contract"

          class_name.constantize
        rescue NameError
          nil
        end

        # Auto-discover the Controller class based on namespaces and resource name
        def infer_controller_class(name)
          # Build class name from namespaces array: [:api, :v1] + :posts -> 'Api::V1::PostsController'
          controller_name = name.to_s.pluralize.camelize
          class_name = "#{namespaces_string}::#{controller_name}Controller"

          class_name.constantize
        rescue NameError
          nil
        end

        def resolve_contract_path(path)
          parts = if path.start_with?('/')
                    # Absolute path: '/admin/post' → 'Admin::PostContract'
                    path[1..].split('/')
                  else
                    # Relative path: 'admin/post' → 'Api::V1::Admin::PostContract'
                    @namespaces + path.split('/')
                  end

          # Camelize all parts and singularize the last part
          parts = parts.map { |part| part.to_s.camelize }
          parts[-1] = parts[-1].singularize

          # Join and append 'Contract'
          "#{parts.join('::')}Contract"
        end
      end
    end
  end
end
