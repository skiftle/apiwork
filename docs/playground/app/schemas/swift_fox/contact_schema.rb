# frozen_string_literal: true

module SwiftFox
  class ContactSchema < Apiwork::Schema::Base
    attribute :id
    attribute :name, writable: true

    attribute :email,
              writable: true,
              encode: ->(v) { v&.downcase },
              decode: ->(v) { v&.upcase }

    attribute :phone, writable: true, empty: true
    attribute :notes, writable: true, empty: true
  end
end
