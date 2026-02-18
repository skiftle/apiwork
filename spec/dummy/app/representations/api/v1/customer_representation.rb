# frozen_string_literal: true

module Api
  module V1
    class CustomerRepresentation < Apiwork::Representation::Base
      attribute :name, writable: true
      attribute :email,
                writable: true,
                filterable: true,
                sortable: true,
                nullable: true,
                encode: ->(value) { value&.downcase },
                decode: ->(value) { value&.upcase }
      attribute :phone, writable: true

      has_many :services
      has_one :address
    end
  end
end
