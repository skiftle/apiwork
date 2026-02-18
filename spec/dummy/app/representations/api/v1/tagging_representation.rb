# frozen_string_literal: true

module Api
  module V1
    class TaggingRepresentation < Apiwork::Representation::Base
      attribute :id
      attribute :tag_id, type: :integer, writable: true
      attribute :created_at
      attribute :updated_at

      belongs_to :tag
    end
  end
end
