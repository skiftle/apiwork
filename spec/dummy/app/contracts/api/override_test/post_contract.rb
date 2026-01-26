# frozen_string_literal: true

module Api
  module OverrideTest
    class PostContract < Apiwork::Contract::Base
      representation PostRepresentation
    end
  end
end
