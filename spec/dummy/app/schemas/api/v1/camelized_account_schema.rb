# frozen_string_literal: true

module Api
  module V1
    class CamelizedAccountSchema < Apiwork::Schema::Base
      model Account

      configure do
        serialize_key_transform :camelize_lower
      end

      attribute :id
      attribute :name
      attribute :status
      attribute :first_day_of_week
    end
  end
end
