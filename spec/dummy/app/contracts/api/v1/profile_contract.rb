# frozen_string_literal: true

module Api
  module V1
    class ProfileContract < Apiwork::Contract::Base
      schema!

      action :show
      action :create
      action :update
      action :destroy
    end
  end
end
