# frozen_string_literal: true

module Api
  module V1
    class ServiceContract < Apiwork::Contract::Base
      schema ServiceSchema
    end
  end
end
