# frozen_string_literal: true

module Api
  module V2
    class CustomerAddressContract < Apiwork::Contract::Base
      representation CustomerAddressRepresentation

      action :index
      action :show
      action :create
      action :update
      action :destroy
    end
  end
end
