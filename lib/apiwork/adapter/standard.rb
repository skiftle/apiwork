# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard < Base
      adapter_name :standard

      transform_request RequestTransformer

      representation Representation::Default
      document Document::Default

      capability Capability::Filtering
      capability Capability::Sorting
      capability Capability::Pagination
      capability Capability::Including
      capability Capability::Writing
    end
  end
end
