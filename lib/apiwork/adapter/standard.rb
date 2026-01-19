# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard < Base
      adapter_name :standard

      option :pagination, type: :hash do
        option :strategy, default: :offset, enum: %i[offset cursor], type: :symbol
        option :default_size, default: 20, type: :integer
        option :max_size, default: 100, type: :integer
      end

      feature Feature::Filtering
      feature Feature::Sorting
      feature Feature::Preloading
      feature Feature::Pagination
      feature Feature::Including

      resource_envelope Envelope::Resource
      error_envelope Envelope::Error

      transform_request RequestTransformer
      transform_request OpFieldTransformer, post: true
    end
  end
end
