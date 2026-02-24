# frozen_string_literal: true

module CuriousCat
  class Profile < ApplicationRecord
    store :settings, accessors: [:theme, :notifications, :language]
    serialize :tags, coder: JSON
    store :metadata, coder: JSON
  end
end
