# frozen_string_literal: true

module Api
  module V1
    class PersonCustomerRepresentation < CustomerRepresentation
      type_name :person

      attribute :born_on, writable: true
    end
  end
end
