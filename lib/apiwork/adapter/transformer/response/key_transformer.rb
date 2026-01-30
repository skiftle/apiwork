# frozen_string_literal: true

module Apiwork
  module Adapter
    module Transformer
      module Response
        class KeyTransformer < Base
          phase :after

          def transform
            case api_class.key_format
            when :camel then camelize
            when :kebab then dasherize
            else response
            end
          end

          private

          def camelize
            response.transform do |hash|
              hash.deep_transform_keys { |key| key.to_s.camelize(:lower).to_sym }
            end
          end

          def dasherize
            response.transform do |hash|
              hash.deep_transform_keys { |key| key.to_s.dasherize.to_sym }
            end
          end
        end
      end
    end
  end
end
