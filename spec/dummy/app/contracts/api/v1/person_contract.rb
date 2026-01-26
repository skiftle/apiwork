# frozen_string_literal: true

module Api
  module V1
    class PersonContract < Apiwork::Contract::Base
      representation PersonRepresentation
    end
  end
end
