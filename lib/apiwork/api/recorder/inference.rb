# frozen_string_literal: true

module Apiwork
  module API
    class Recorder
      module Inference
        private

        def infer_contract_class_name(name)
          contract_name = name.to_s.singularize.camelize
          "#{namespaces_string}::#{contract_name}Contract"
        end

        def contract_path_to_class_name(path)
          parts = if path.start_with?('/')
                    path[1..].split('/')
                  else
                    @namespaces + path.split('/')
                  end

          parts = parts.map { |part| part.to_s.camelize }
          parts[-1] = parts[-1].singularize

          "#{parts.join('::')}Contract"
        end
      end
    end
  end
end
