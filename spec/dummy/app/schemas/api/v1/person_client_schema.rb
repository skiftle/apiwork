# frozen_string_literal: true

module Api
  module V1
    class PersonClientSchema < ClientSchema
      model PersonClient
      variant as: "person"

      attribute :birth_date
    end
  end
end
