# frozen_string_literal: true

module Api
  module V1
    class PersonClientContract < Apiwork::Contract::Base
      schema Api::V1::PersonClientSchema
    end
  end
end
