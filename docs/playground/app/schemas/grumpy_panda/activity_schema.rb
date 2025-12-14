# frozen_string_literal: true

module GrumpyPanda
  class ActivitySchema < Apiwork::Schema::Base
    adapter do
      pagination do
        strategy :cursor
        default_size 3
      end
    end

    attribute :id
    attribute :action, writable: true
    attribute :occurred_at, writable: true
    attribute :created_at
  end
end
