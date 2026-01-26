# frozen_string_literal: true

module Api
  module V1
    class AuthorContract < Apiwork::Contract::Base
      representation AuthorRepresentation
    end
  end
end
