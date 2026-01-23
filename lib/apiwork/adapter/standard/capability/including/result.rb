# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Capability
        class Including
          class Result < Adapter::Capability::Result::Base
            def apply
              include_params = request.query[:include] || {}

              resolver = IncludesResolver.new(schema_class)
              always = resolver.always_included
              explicit = build_explicit_includes(include_params, schema_class)

              includes = IncludesResolver.deep_merge_includes(always, explicit).keys

              result(data:, includes:, serialize_options: { include: include_params })
            end

            private

            def build_explicit_includes(params, schema_class)
              return {} if params.blank?

              result = {}
              params.each do |key, value|
                key = key.to_sym
                next if [false, 'false'].include?(value)

                result[key] = value.is_a?(Hash) ? build_explicit_includes(value, schema_class) : {}
              end
              result
            end
          end
        end
      end
    end
  end
end
