# frozen_string_literal: true

module CalmTurtle
  class CustomerContract < Apiwork::Contract::Base
    object :address do
      string :street
      string :city
      string :country
    end

    object :customer do
      uuid :id
      string :name
      reference :billing_address, to: :address
      datetime :created_at
      datetime :updated_at
    end

    object :create_payload do
      string :name
      reference :billing_address, to: :address
    end

    action :create do
      request do
        body do
          reference :customer, to: :create_payload
        end
      end

      response do
        body do
          reference :customer
        end
      end
    end
  end
end
