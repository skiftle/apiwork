# frozen_string_literal: true

module Api
  module V1
    class CompanyClientContract < Apiwork::Contract::Base
      representation CompanyClientRepresentation
    end
  end
end
