# frozen_string_literal: true

module Api
  module V1
    class PersonClientRepresentation < ClientRepresentation
      model PersonClient
      variant as: :person

      attribute :birth_date, writable: true
    end
  end
end
