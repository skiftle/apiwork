# frozen_string_literal: true

module Apiwork
  module Concerns
    # Provides safe constantization with proper error handling
    module SafeConstantize
      def constantize_safe(class_name)
        class_name.constantize
      rescue NameError
        nil
      end
    end
  end
end
