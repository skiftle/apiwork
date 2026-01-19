# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Feature
        class Including < Adapter::Feature
          feature_name :including
          applies_to :index, :show
          input :any

          def contract(registrar, schema_class)
            TypeBuilder.build(registrar, schema_class)
          end

          def extract(request, schema_class)
            request&.query&.dig(:include) || {}
          end

          def includes(params, schema_class)
            resolver = IncludesResolver.new(schema_class)
            always = resolver.always_included
            explicit = build_explicit_includes(params, schema_class)

            IncludesResolver.deep_merge_includes(always, explicit).keys
          end

          def apply(data, params, context)
            data.merge(serialize_includes: params)
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
