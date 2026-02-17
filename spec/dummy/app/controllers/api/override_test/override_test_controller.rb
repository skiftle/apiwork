# frozen_string_literal: true

module Api
  module OverrideTest
    class OverrideTestController < ApplicationController
      include Apiwork::Controller

      rescue_from ActiveRecord::RecordNotFound do
        expose_error :not_found
      end
    end
  end
end
