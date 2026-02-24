# frozen_string_literal: true

module HappyZebra
  class CommentRepresentation < Apiwork::Representation::Base
    attribute :id
    attribute :body, writable: true
    attribute :author, writable: true
  end
end
