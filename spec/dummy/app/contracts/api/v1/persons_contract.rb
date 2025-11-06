# frozen_string_literal: true

module Api
  module V1
    # PersonContract - Contract for PersonSchema
    # Demonstrates custom root key usage in contracts
    class PersonsContract < Apiwork::Contract::Base
      schema 'Api::V1::Api::V1::PersonSchema

      # Note: create/update will auto-generate with wrapping key 'person'
      # (derived from PersonResource.root_key.singular)
    end
  end
end
