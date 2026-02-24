# frozen_string_literal: true

module Apiwork
  module Adapter
    module Wrapper
      module Error
        # @api public
        # Base class for error response wrappers.
        #
        # Error wrappers structure responses for validation errors and other
        # error conditions. Extend this class to customize how errors are
        # wrapped in your API responses.
        #
        # @example Custom error wrapper
        #   class MyErrorWrapper < Wrapper::Error::Base
        #     shape do
        #       extends(data_type)
        #     end
        #
        #     def wrap
        #       data
        #     end
        #   end
        class Base < Wrapper::Base
          self.wrapper_type = :error
        end
      end
    end
  end
end
