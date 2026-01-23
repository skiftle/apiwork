# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Capability
        class Including
          class Computation < Adapter::Capability::Computation::Base
            def apply
              include_params = request.query[:include] || {}

              resolver = IncludesResolver.new(schema_class)
              includes = IncludesResolver.merge(resolver.always_included, resolver.from_params(include_params)).keys

              result(data:, includes:, serialize_options: { include: include_params })
            end
          end
        end
      end
    end
  end
end
