# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Capability
        class Writing < Adapter::Capability::Base
          capability_name :writing
          applies_to :create, :update
          input :record

          request_transformer OpFieldTransformer, post: true

          contract Contract
          result Result
        end
      end
    end
  end
end
