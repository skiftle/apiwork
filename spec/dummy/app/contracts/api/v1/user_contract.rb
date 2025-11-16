# frozen_string_literal: true

module Api
  module V1
    class UserContract < Apiwork::Contract::Base
      schema UserSchema

      action :index
      action :show
      action :create
      action :update
      action :destroy
    end
  end
end
