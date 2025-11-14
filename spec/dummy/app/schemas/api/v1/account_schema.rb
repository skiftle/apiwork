# frozen_string_literal: true

module Api
  module V1
    class AccountSchema < Apiwork::Schema::Base
      model Account

      attribute :id
      attribute :name
      attribute :status
      attribute :first_day_of_week
    end
  end
end
