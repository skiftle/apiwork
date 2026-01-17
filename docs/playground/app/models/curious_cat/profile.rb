# frozen_string_literal: true

module CuriousCat
  class Profile < ApplicationRecord
    # settings is a JSON column - no coder needed
    store :settings, accessors: [:theme, :notifications, :language]
    # tags is a text column - needs JSON coder
    serialize :tags, coder: JSON
    # metadata is a text column - needs JSON coder
    store :metadata, coder: JSON
  end
end
