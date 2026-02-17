# frozen_string_literal: true

module Api
  module V1
    class SafeItemContract < Apiwork::Contract::Base
      representation SafeItemRepresentation
    end
  end
end
