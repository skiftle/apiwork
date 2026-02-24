# frozen_string_literal: true

module SwiftFox
  class ContactRepresentation < Apiwork::Representation::Base
    attribute :id
    attribute :name, writable: true

    attribute :email, decode: ->(v) { v&.downcase }, encode: ->(v) { v&.downcase }, writable: true

    attribute :phone, empty: true, writable: true
    attribute :notes, empty: true, writable: true
    attribute :created_at
    attribute :updated_at
  end
end
