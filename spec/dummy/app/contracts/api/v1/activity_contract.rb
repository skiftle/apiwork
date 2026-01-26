# frozen_string_literal: true

module Api
  module V1
    class ActivityContract < Apiwork::Contract::Base
      representation ActivityRepresentation
    end
  end
end
