# frozen_string_literal: true

class UserProfile < ApplicationRecord
  self.table_name = 'profiles'

  belongs_to :user
end
