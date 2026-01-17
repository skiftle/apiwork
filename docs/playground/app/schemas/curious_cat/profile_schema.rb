# frozen_string_literal: true

module CuriousCat
  class ProfileSchema < Apiwork::Schema::Base
    attribute :id
    attribute :name, writable: true
    attribute :email, format: :email, writable: true

    attribute :settings, writable: true do
      object do
        string :theme
        boolean :notifications
        string :language
      end
    end

    attribute :tags, writable: true do
      array do
        string
      end
    end

    attribute :addresses, writable: true do
      array do
        object do
          string :street
          string :city
          string :zip
          boolean :primary
        end
      end
    end

    attribute :preferences, writable: true do
      object do
        object :ui do
          string :theme
          boolean :sidebar_collapsed
        end
        object :notifications do
          boolean :email
          boolean :push
        end
      end
    end

    attribute :metadata, type: :unknown, writable: true

    attribute :created_at
    attribute :updated_at
  end
end
