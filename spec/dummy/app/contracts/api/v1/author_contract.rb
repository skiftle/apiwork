# frozen_string_literal: true

module Api
  module V1
    # AuthorContract - Test contract for writable context filtering
    # Uses auto-generated inputs from AuthorSchema
    class AuthorContract < Apiwork::Contract::Base
      schema AuthorSchema

      # Standard CRUD actions use auto-generated inputs from schema
      # No explicit input blocks - tests writable context filtering
    end
  end
end
