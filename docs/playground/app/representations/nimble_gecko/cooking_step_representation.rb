# frozen_string_literal: true

module NimbleGecko
  class CookingStepRepresentation < Apiwork::Representation::Base
    attribute :id
    attribute :step_number, writable: true
    attribute :instruction, writable: true
    attribute :duration_minutes, writable: true
  end
end
