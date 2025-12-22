# frozen_string_literal: true

module CuriousCat
  class Profile < ApplicationRecord
    store_accessor :settings, :theme, :notifications, :language
    serialize :tags, coder: JSON
    store :metadata, coder: JSON
  end
end
