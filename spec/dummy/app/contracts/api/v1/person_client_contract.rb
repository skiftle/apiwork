# frozen_string_literal: true

module Api
  module V1
    class PersonClientContract < Apiwork::Contract::Base
      representation PersonClientRepresentation
    end
  end
end
