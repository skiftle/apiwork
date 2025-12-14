# frozen_string_literal: true

module HappyZebra
  class CommentSchema < Apiwork::Schema::Base
    attribute :id
    attribute :body, writable: true
    attribute :author, writable: true
  end
end
