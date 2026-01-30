# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Capability
        class Including
          class Computation < Adapter::Capability::Computation::Base
            def apply
              params = request.query[:include] || {}
              includes = IncludesResolver.new(representation_class).resolve(params)

              result(data:, includes:, serialize_options: { include: params })
            end
          end
        end
      end
    end
  end
end
