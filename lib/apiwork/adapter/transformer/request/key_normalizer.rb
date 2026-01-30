# frozen_string_literal: true

module Apiwork
  module Adapter
    module Transformer
      module Request
        class KeyNormalizer < Base
          phase :before

          def transform
            return request unless normalize?

            request.transform do |hash|
              hash.deep_transform_keys { |key| key.to_s.underscore.to_sym }
            end
          end

          private

          def normalize?
            %i[camel kebab].include?(api_class.key_format)
          end
        end
      end
    end
  end
end
