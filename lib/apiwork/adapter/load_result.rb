# frozen_string_literal: true

module Apiwork
  module Adapter
    class LoadResult
      attr_reader :data,
                  :metadata

      def initialize(data, metadata = {})
        @data = data
        @metadata = metadata
      end
    end
  end
end
