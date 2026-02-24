# frozen_string_literal: true

module Apiwork
  class ErrorsController < ActionController::API
    include Controller

    skip_contract_validation!

    def not_found
      expose_error :not_found
    end
  end
end
