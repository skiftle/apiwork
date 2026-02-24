# frozen_string_literal: true

module Api
  module V1
    class ProfileContract < ApplicationContract
      representation ProfileRepresentation

      action :show
      action :create
      action :update
      action :destroy
    end
  end
end
