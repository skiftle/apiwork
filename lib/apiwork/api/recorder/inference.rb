# frozen_string_literal: true

module Apiwork
  module API
    class Recorder
      # Handles inferring resource class names
      module Inference
        private

        # Auto-discover the Resource class based on namespaces and resource name
        def infer_resource_class(name)
          # Build class name from namespaces array: [:api, :v1] -> 'Api::V1::AccountResource'
          resource_name = name.to_s.singularize.camelize
          class_name = "#{namespaces_string}::#{resource_name}Resource"

          class_name.constantize
        rescue NameError => e
          ::Rails.logger&.warn "Could not find resource class: #{class_name}. Error: #{e.message}"
          nil
        end
      end
    end
  end
end
