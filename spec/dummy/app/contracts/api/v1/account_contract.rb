# frozen_string_literal: true

module Api
  module V1
    class AccountContract < Apiwork::Contract::Base
      representation AccountRepresentation

      action :show
    end
  end
end
