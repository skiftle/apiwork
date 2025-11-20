# frozen_string_literal: true

module Api
  module V1
    class ServiceContract < Apiwork::Contract::Base
      schema Api::V1::ServiceSchema
    end
  end
end
