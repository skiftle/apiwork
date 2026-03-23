# frozen_string_literal: true

module CuriousCat
  class Profile < ApplicationRecord
    store_accessor :settings, :theme, :language

    def stats
      {
        addresses: addresses.length,
        tags: tags.length,
      }
    end
  end
end
