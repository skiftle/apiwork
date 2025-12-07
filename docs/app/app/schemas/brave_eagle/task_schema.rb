# frozen_string_literal: true

module BraveEagle
  class TaskSchema < Apiwork::Schema::Base
    attribute :id
    attribute :title, writable: true
    attribute :description, writable: true
    attribute :status, writable: true, filterable: true
    attribute :priority, writable: true, filterable: true
    attribute :due_date, writable: true, sortable: true
    attribute :archived
    attribute :created_at, sortable: true
    attribute :updated_at
  end
end
