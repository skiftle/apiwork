# frozen_string_literal: true

module CalmTurtle
  class CustomerContract < Apiwork::Contract::Base
    representation CustomerRepresentation

    object :address do
      string :street
      string :city
      string :country
    end
  end
end
