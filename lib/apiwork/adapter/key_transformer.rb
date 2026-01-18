# frozen_string_literal: true

module Apiwork
  module Adapter
    class KeyTransformer
      def call(response, api_class:)
        case api_class.key_format
        when :camel
          response.transform do |hash|
            hash.deep_transform_keys { |key| key.to_s.camelize(:lower).to_sym }
          end
        when :kebab
          response.transform do |hash|
            hash.deep_transform_keys { |key| key.to_s.dasherize.to_sym }
          end
        else
          response
        end
      end
    end
  end
end
