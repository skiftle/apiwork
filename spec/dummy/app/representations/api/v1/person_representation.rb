# frozen_string_literal: true

module Api
  module V1
    # PersonRepresentation - Demonstrates irregular pluralization
    # Uses Post model but serializes with person/people root keys
    class PersonRepresentation < Apiwork::Representation::Base
      model Post
      root :person, :people  # Explicit plural for irregular word

      attribute :id, filterable: true, sortable: true
      attribute :title, writable: true, filterable: true, sortable: true
      attribute :body, writable: true, filterable: true, sortable: true
      attribute :published, writable: true, filterable: true, sortable: true
      # Demonstrates root key override with full attribute set
    end
  end
end
