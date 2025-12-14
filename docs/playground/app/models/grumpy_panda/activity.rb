# frozen_string_literal: true

module GrumpyPanda
  class Activity < ApplicationRecord
    validates :action, presence: true
  end
end
