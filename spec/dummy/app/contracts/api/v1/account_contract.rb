# frozen_string_literal: true

module Api
  module V1
    class AccountContract < Apiwork::Contract::Base
      schema!

      action :show
    end
  end
end
