# frozen_string_literal: true

module GrumpyPanda
  class OrderContract < Apiwork::Contract::Base
    action :create do
      request do
        body do
          param :shipping_address, type: :object do
            param :street, type: :string
            param :city, type: :string
          end
        end
      end

      response do
        body do
          param :id, type: :integer
          param :status, type: :string
        end
      end
    end
  end
end
