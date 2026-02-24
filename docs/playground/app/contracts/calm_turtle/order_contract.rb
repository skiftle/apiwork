# frozen_string_literal: true

module CalmTurtle
  class OrderContract < Apiwork::Contract::Base
    representation OrderRepresentation

    import CustomerContract, as: :customer
  end
end
