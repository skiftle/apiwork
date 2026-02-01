# frozen_string_literal: true

module Api
  module V1
    class PersonClientRepresentation < ClientRepresentation
      model PersonClient
      sti_name :person

      attribute :birth_date, writable: true
    end
  end
end
