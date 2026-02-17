# frozen_string_literal: true

module Api
  module V1
    class AdjustmentRepresentation < Apiwork::Representation::Base
      attribute :description, writable: true
      attribute :amount, writable: true
      attribute :created_at
      attribute :updated_at
    end
  end
end
