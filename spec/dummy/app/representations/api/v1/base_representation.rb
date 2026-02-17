# frozen_string_literal: true

module Api
  module V1
    class BaseRepresentation < Apiwork::Representation::Base
      abstract!
    end
  end
end
