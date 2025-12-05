# frozen_string_literal: true

module FriendlyTiger
  class OrderContract < Apiwork::Contract::Base
    type :address do
      param :street, type: :string
      param :city, type: :string
    end

    enum :priority, values: %w[low normal high urgent]

    action :create do
      request do
        body do
          param :shipping_address, type: :address
          param :priority, type: :priority
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
