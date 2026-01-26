# frozen_string_literal: true

module Api
  module V1
    class ClientContract < Apiwork::Contract::Base
      representation ClientRepresentation
    end
  end
end
