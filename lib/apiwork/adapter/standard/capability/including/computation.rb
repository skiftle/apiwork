# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Capability
        class Including
          class Computation < Adapter::Capability::Computation::Base
            def apply
              params = request.query[:include] || {}

              resolver = IncludesResolver.new(representation_class)
              includes = IncludesResolver.merge(resolver.always_included, resolver.from_params(params)).keys

              result(data:, includes:, serialize_options: { include: params })
            end
          end
        end
      end
    end
  end
end
