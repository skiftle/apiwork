# frozen_string_literal: true

module CuriousCat
  class ProfileRepresentation < Apiwork::Representation::Base
    object :address do
      string :street
      string :city
      string :zip
    end

    object :stats do
      integer :tags
      integer :addresses
    end

    attribute :id
    attribute :name, writable: true
    attribute :email, format: :email, writable: true

    attribute :settings, writable: true do
      object do
        string :theme
        string :language
      end
    end

    attribute :tags, writable: true do
      array do
        string
      end
    end

    attribute :primary_address, type: :address, writable: true

    attribute :addresses, writable: true do
      array do
        reference :address
      end
    end

    attribute :stats, type: :stats

    attribute :created_at
    attribute :updated_at
  end
end
