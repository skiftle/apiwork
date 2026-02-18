# frozen_string_literal: true

module Api
  module V1
    class AdjustmentRepresentation < Apiwork::Representation::Base
      attribute :amount, writable: true
      attribute :created_at
      attribute :description, writable: true
      attribute :updated_at
    end
  end
end
