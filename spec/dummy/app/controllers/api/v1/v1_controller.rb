# frozen_string_literal: true

module Api
  module V1
    class V1Controller < ApplicationController
      include Apiwork::Controller

      rescue_from ActiveRecord::RecordNotFound do
        respond_with_error :not_found
      end
    end
  end
end
