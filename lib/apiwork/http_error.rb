# frozen_string_literal: true

module Apiwork
  class HttpError < ConstraintError
    attr_reader :error_code

    def initialize(issues, error_code)
      @error_code = error_code
      super(issues)
    end

    def layer
      :http
    end
  end
end
