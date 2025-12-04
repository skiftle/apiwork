# frozen_string_literal: true

module Apiwork
  class ErrorsController < ActionController::API
    include Apiwork::Controller

    skip_contract_validation!

    def not_found
      respond_with_error :not_found
    end
  end
end
