# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Capability
        class Including < Adapter::Capability::Base
          capability_name :including
          input :any

          def contract_types(registrar, schema_class, actions)
            TypeBuilder.build(registrar, schema_class)

            return unless registrar.type?(:include)

            actions.each_key do |action_name|
              registrar.action(action_name) do
                request do
                  query do
                    reference? :include
                  end
                end
              end
            end
          end

          def extract(request, schema_class)
            request.query[:include] || {}
          end

          def includes(params, schema_class)
            resolver = IncludesResolver.new(schema_class)
            always = resolver.always_included
            explicit = build_explicit_includes(params, schema_class)

            IncludesResolver.deep_merge_includes(always, explicit).keys
          end

          def serialize_options(params, schema_class)
            { include: params }
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
