# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard < Base
      adapter_name :standard

      resource_serializer Serializer::Resource::Default
      error_serializer Serializer::Error::Default

      record_wrapper Wrapper::Record::Default
      collection_wrapper Wrapper::Collection::Default
      error_wrapper Wrapper::Error::Default

      capability Capability::Filtering
      capability Capability::Sorting
      capability Capability::Pagination
      capability Capability::Including
      capability Capability::Writing
    end
  end
end
