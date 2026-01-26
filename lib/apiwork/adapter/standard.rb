# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard < Base
      adapter_name :standard

      transform_request RequestTransformer

      serialization Serialization::Default

      record_document Document::Record::Default
      collection_document Document::Collection::Default
      error_document Document::Error::Default

      capability Capability::Filtering
      capability Capability::Sorting
      capability Capability::Pagination
      capability Capability::Including
      capability Capability::Writing
    end
  end
end
