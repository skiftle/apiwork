# frozen_string_literal: true

module Api
  module V1
    class ServiceContract < Apiwork::Contract::Base
      representation ServiceRepresentation
    end
  end
end
