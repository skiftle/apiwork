# frozen_string_literal: true

module SwiftFox
  class Contact < ApplicationRecord
    validates :name, presence: true
  end
end
