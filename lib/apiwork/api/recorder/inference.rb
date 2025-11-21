# frozen_string_literal: true

module Apiwork
  module API
    class Recorder
      module Inference
        private

        def infer_resource_class(name)
          resource_name = name.to_s.singularize.camelize
          class_name = "#{namespaces_string}::#{resource_name}Schema"

          class_name.constantize
        rescue NameError
          nil
        end

        def infer_contract_class(name)
          contract_name = name.to_s.singularize.camelize
          class_name = "#{namespaces_string}::#{contract_name}Contract"

          class_name.constantize
        rescue NameError
          nil
        end

        def constantize_contract_path(path)
          parts = if path.start_with?('/')
                    path[1..].split('/')
                  else
                    @namespaces + path.split('/')
                  end

          parts = parts.map { |part| part.to_s.camelize }
          parts[-1] = parts[-1].singularize

          class_name = "#{parts.join('::')}Contract"
          class_name.constantize
        rescue NameError
          nil
        end
      end
    end
  end
end
