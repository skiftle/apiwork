# frozen_string_literal: true

module Apiwork
  module Adapter
    module Wrapper
      module Error
        class Base < Wrapper::Base
          wrapper_type :error
        end
      end
    end
  end
end
