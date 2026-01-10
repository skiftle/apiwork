# frozen_string_literal: true

module CuriousCat
  class ProfileSchema < Apiwork::Schema::Base
    attribute :id
    attribute :name, writable: true
    attribute :email, format: :email, writable: true

    attribute :settings, writable: true do
      string :theme
      boolean :notifications
      string :language
    end

    attribute :tags, type: :array, writable: true do
      string
    end

    attribute :addresses, type: :array, writable: true do
      object do
        string :street
        string :city
        string :zip
        boolean :primary
      end
    end

    attribute :preferences, writable: true do
      object :ui do
        string :theme
        boolean :sidebar_collapsed
      end
      object :notifications do
        boolean :email
        boolean :push
      end
    end

    attribute :metadata, type: :json, writable: true

    attribute :created_at
    attribute :updated_at
  end
end
