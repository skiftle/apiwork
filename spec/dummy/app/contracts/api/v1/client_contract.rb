# frozen_string_literal: true

module Api
  module V1
    class ClientContract < Apiwork::Contract::Base
      schema!

      # Explicitly register STI variants to ensure they're loaded before type generation
      register_sti_variants PersonClientSchema, CompanyClientSchema
    end
  end
end
