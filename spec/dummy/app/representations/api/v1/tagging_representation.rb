# frozen_string_literal: true

module Api
  module V1
    class TaggingRepresentation < Apiwork::Representation::Base
      attribute :created_at
      attribute :id
      attribute :tag_id, type: :integer, writable: true
      attribute :updated_at

      belongs_to :tag
    end
  end
end
