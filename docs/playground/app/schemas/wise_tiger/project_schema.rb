# frozen_string_literal: true

module WiseTiger
  class ProjectSchema < Apiwork::Schema::Base
    attribute :id
    attribute :name, writable: true
    attribute :description, writable: true
    attribute :status, writable: true, filterable: true
    attribute :priority, writable: true, filterable: true
    attribute :deadline, writable: true, sortable: true
    attribute :created_at, sortable: true
    attribute :updated_at
  end
end
