# frozen_string_literal: true

module Api
  module V1
    class ClientContract < Apiwork::Contract::Base
      schema Api::V1::ClientSchema
    end
  end
end
