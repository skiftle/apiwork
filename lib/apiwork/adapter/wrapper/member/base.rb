# frozen_string_literal: true

module Apiwork
  module Adapter
    module Wrapper
      module Member
        class Base < Wrapper::Base
          wrapper_type :member

          attr_reader :meta, :metadata, :root_key

          def initialize(data, metadata, root_key, meta)
            super(data)
            @metadata = metadata
            @root_key = root_key
            @meta = meta
          end
        end
      end
    end
  end
end
