# frozen_string_literal: true

class Activity < ApplicationRecord
  belongs_to :target, polymorphic: true, optional: true
end
