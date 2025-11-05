# frozen_string_literal: true

module Api
  module V1
    # PersonResource - Demonstrates irregular pluralization
    # Uses Post model but serializes with person/people root keys
    class PersonResource < Apiwork::Resource::Base
      model Post
      root :person, :people  # Explicit plural for irregular word

      attribute :id
      attribute :title, writable: true
      attribute :body, writable: true
      attribute :published, writable: true
      # Demonstrates root key override with full attribute set
    end
  end
end
