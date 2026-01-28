# frozen_string_literal: true

module Apiwork
  module Adapter
    module Document
      module Error
        class Base < Document::Base
          def initialize(data) # rubocop:disable Lint/MissingSuper
            @data = data
          end
        end
      end
    end
  end
end
