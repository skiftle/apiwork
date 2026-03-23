# frozen_string_literal: true

module CalmTurtle
  class OrderContract < Apiwork::Contract::Base
    import CustomerContract, as: :customer

    object :order do
      uuid :id
      string :order_number
      reference :shipping_address, to: :customer_address
      datetime :created_at
      datetime :updated_at
    end

    object :create_payload do
      string :order_number
      reference :shipping_address, to: :customer_address
    end

    action :create do
      request do
        body do
          reference :order, to: :create_payload
        end
      end

      response do
        body do
          reference :order
        end
      end
    end
  end
end
