# frozen_string_literal: true

module Api
  module V1
    class AttachmentRepresentation < Apiwork::Representation::Base
      attribute :created_at
      attribute :filename
      attribute :id
    end
  end
end
