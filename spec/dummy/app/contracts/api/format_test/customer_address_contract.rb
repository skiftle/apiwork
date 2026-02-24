# frozen_string_literal: true

module Api
  module FormatTest
    class CustomerAddressContract < ApplicationContract
      representation CustomerAddressRepresentation

      action :index
      action :show
      action :create
      action :update
      action :destroy
    end
  end
end
