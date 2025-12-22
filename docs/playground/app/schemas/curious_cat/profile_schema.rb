# frozen_string_literal: true

module CuriousCat
  class ProfileSchema < Apiwork::Schema::Base
    attribute :id
    attribute :name, writable: true
    attribute :email, writable: true, format: :email

    attribute :settings, writable: true do
      param :theme, type: :string
      param :notifications, type: :boolean
      param :language, type: :string
    end

    attribute :tags, type: :array, of: :string, writable: true

    attribute :addresses, type: :array, writable: true do
      param :street, type: :string
      param :city, type: :string
      param :zip, type: :string
      param :primary, type: :boolean
    end

    attribute :preferences, writable: true do
      param :ui, type: :object do
        param :theme, type: :string
        param :sidebar_collapsed, type: :boolean
      end
      param :notifications, type: :object do
        param :email, type: :boolean
        param :push, type: :boolean
      end
    end

    attribute :metadata, type: :json, writable: true

    attribute :created_at
    attribute :updated_at
  end
end
