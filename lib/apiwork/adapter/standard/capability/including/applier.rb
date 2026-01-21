# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Capability
        class Including
          class Applier < Adapter::Capability::Applier::Base
            def extract
              context.request.query[:include] || {}
            end

            def includes
              resolver = IncludesResolver.new(context.schema_class)
              always = resolver.always_included
              explicit = build_explicit_includes(context.params, context.schema_class)

              IncludesResolver.deep_merge_includes(always, explicit).keys
            end

            def serialize_options
              { include: context.params }
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
