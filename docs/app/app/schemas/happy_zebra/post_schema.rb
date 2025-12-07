# frozen_string_literal: true

module HappyZebra
  class PostSchema < Apiwork::Schema::Base
    attribute :id
    attribute :title, writable: true

    has_many :comments, schema: CommentSchema, writable: true, include: :always
  end
end
