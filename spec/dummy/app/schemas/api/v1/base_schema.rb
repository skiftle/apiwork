# frozen_string_literal: true

module Api
  module V1
    # Abstract base schema for V1 API
    # Tests that auto-detection works correctly with abstract base classes
    class BaseSchema < Apiwork::Schema::Base
      self.abstract_class = true
    end
  end
end
