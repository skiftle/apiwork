# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard < Base
      adapter_name :standard

      transform_request RequestTransformer

      feature Feature::Filtering
      feature Feature::Sorting
      feature Feature::Pagination
      feature Feature::Including
      feature Feature::Writing
      feature Feature::Serialization

      resource_envelope Envelope::Resource
      error_envelope Envelope::Error
    end
  end
end
