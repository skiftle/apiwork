# frozen_string_literal: true

module Api
  module V1
    class ItemContract < Apiwork::Contract::Base
      representation ItemRepresentation
    end
  end
end
