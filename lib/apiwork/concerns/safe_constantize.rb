# frozen_string_literal: true

module Apiwork
  module Concerns
    # Provides safe constantization with proper error handling
    module SafeConstantize
      # Safely constantize a class name string
      # Returns nil if the constant cannot be found
      #
      # @param class_name [String] The class name to constantize
      # @return [Class, nil] The constantized class or nil
      def constantize_safe(class_name)
        class_name.constantize
      rescue NameError
        nil
      end
    end
  end
end
