# frozen_string_literal: true

module Api
  module V1
    class ServiceContract < ApplicationContract
      representation ServiceRepresentation

      action :archive do
        raises :forbidden
      end

      action :expire do
        raises :not_found
      end

      action :restrict do
        raises :forbidden
      end
    end
  end
end
