# frozen_string_literal: true

module WiseTiger
  class ProjectSchema < Apiwork::Schema::Base
    description 'A project with tasks and deadlines'

    attribute :id
    attribute :name, writable: true
    attribute :description, writable: true
    attribute :status, filterable: true, writable: true
    attribute :priority, filterable: true, writable: true
    attribute :deadline, sortable: true, writable: true
    attribute :created_at, sortable: true
    attribute :updated_at
  end
end
