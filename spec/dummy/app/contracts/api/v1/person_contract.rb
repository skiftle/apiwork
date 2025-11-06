# frozen_string_literal: true

module Api
  module V1
    # PersonContract - Contract for PersonSchema
    # Demonstrates custom root key usage in contracts
    class PersonContract < Apiwork::Contract::Base
      schema PersonSchema

      # Note: create/update will auto-generate with wrapping key 'person'
      # (derived from PersonSchema.root_key.singular)
    end
  end
end
