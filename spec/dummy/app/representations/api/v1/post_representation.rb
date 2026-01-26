# frozen_string_literal: true

module Api
  module V1
    class PostRepresentation < Apiwork::Representation::Base


      with_options filterable: true, sortable: true do
        attribute :id
        attribute :created_at
        attribute :updated_at

        with_options writable: true do
          attribute :title
          attribute :body, description: 'The main content of the post'
          attribute :published
          attribute :metadata
        end
      end

      has_many :attachments
      has_many :comments, representation: CommentRepresentation, writable: true, filterable: true, sortable: true
    end
  end
end
