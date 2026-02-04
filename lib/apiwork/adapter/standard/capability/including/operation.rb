# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Capability
        class Including
          class Operation < Adapter::Capability::Operation::Base
            def apply
              params = request.query.fetch(:include, {})
              includes = IncludesResolver.resolve(representation_class, params, include_always: true)

              result(includes:, serialize_options: { include: params })
            end
          end
        end
      end
    end
  end
end
