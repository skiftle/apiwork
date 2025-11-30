# frozen_string_literal: true

module EagerLion
  class Line < ApplicationRecord
    self.table_name = 'eager_lion_lines'

    belongs_to :invoice, class_name: 'EagerLion::Invoice'
  end
end
