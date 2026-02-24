# frozen_string_literal: true

module HappyZebra
  class PostRepresentation < Apiwork::Representation::Base
    attribute :id
    attribute :title, writable: true

    has_many :comments, include: :always, writable: true
  end
end
