# frozen_string_literal: true

module Api
  module V1
    class CustomerRepresentation < Apiwork::Representation::Base
      with_options writable: true do
        attribute :email,
                  decode: ->(value) { value&.upcase },
                  encode: ->(value) { value&.downcase },
                  filterable: true,
                  nullable: true,
                  sortable: true
        attribute :name
        attribute :phone
      end

      has_one :address
      has_many :services
    end
  end
end
