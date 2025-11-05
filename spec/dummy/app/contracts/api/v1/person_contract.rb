# frozen_string_literal: true

module Api
  module V1
    # PersonContract - Contract for PersonResource
    # Demonstrates custom root key usage in contracts
    class PersonContract < Apiwork::Contract::Base
      resource Api::V1::PersonResource

      # Note: create/update will auto-generate with wrapping key 'person'
      # (derived from PersonResource.root_key.singular)
    end
  end
end
