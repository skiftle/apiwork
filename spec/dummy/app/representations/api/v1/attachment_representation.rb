# frozen_string_literal: true

module Api
  module V1
    class AttachmentRepresentation < Apiwork::Representation::Base
      attribute :id
      attribute :filename
      attribute :created_at
    end
  end
end
