# frozen_string_literal: true

class Activity < ApplicationRecord
  belongs_to :target, optional: true, polymorphic: true
end
