# frozen_string_literal: true

module Api
  class ApiController < ApplicationController
    include Apiwork::Controller

    rescue_from ActiveRecord::RecordNotFound do
      expose_error :not_found
    end
  end
end
