# frozen_string_literal: true

module EagerLion
  class Line < ApplicationRecord
    belongs_to :invoice
  end
end
