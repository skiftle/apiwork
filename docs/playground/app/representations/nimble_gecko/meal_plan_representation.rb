# frozen_string_literal: true

module NimbleGecko
  class MealPlanRepresentation < Apiwork::Representation::Base
    attribute :id
    attribute :title, writable: true
    attribute :cook_time, writable: true
    attribute :serving_size, writable: true
    attribute :created_at
    attribute :updated_at

    has_many :cooking_steps, include: :always, writable: true
  end
end
