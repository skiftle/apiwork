# frozen_string_literal: true

module Api
  module V1
    class PersonContract < Apiwork::Contract::Base
      schema Api::V1::PersonSchema
    end
  end
end
