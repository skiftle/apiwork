# frozen_string_literal: true

module Apiwork
  module Adapter
    class KeyNormalizer
      def call(request, api_class:)
        return request unless %i[camel kebab].include?(api_class.key_format)

        request.transform do |hash|
          hash.deep_transform_keys { |key| key.to_s.underscore.to_sym }
        end
      end
    end
  end
end
