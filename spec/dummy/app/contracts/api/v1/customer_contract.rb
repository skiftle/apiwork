# frozen_string_literal: true

module Api
  module V1
    class CustomerContract < Apiwork::Contract::Base
      representation CustomerRepresentation
    end
  end
end
