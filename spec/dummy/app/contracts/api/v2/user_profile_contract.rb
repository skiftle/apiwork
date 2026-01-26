# frozen_string_literal: true

module Api
  module V2
    class UserProfileContract < Apiwork::Contract::Base
      representation UserProfileRepresentation

      action :index
      action :show
      action :create
      action :update
      action :destroy
    end
  end
end
