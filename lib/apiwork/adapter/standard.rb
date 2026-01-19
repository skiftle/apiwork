# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard < Base
      adapter_name :standard

      transform_request RequestTransformer
      transform_request OpFieldTransformer, post: true

      resource_envelope Envelope::Resource
      error_envelope Envelope::Error

      feature Feature::Filtering
      feature Feature::Sorting
      feature Feature::Pagination
      feature Feature::Including
    end
  end
end
