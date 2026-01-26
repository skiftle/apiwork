# frozen_string_literal: true

module Api
  module V1
    class CamelizedAccountContract < Apiwork::Contract::Base
      representation CamelizedAccountRepresentation
    end
  end
end
