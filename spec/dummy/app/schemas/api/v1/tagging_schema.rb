# frozen_string_literal: true

module Api
  module V1
    class TaggingSchema < Apiwork::Schema::Base
      attribute :id
      attribute :tag_id, type: :integer, writable: true
      attribute :created_at
      attribute :updated_at

      belongs_to :tag, schema: TagSchema, include: :optional
      # Note: taggable polymorphic association is not exposed in API
      # The polymorphic relationship is handled internally by Rails
    end
  end
end
