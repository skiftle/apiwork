# frozen_string_literal: true

module Api
  module V1
    class ReplySchema < Apiwork::Schema::Base
      attribute :content, writable: true
      attribute :author, writable: true
      attribute :created_at
      attribute :updated_at
    end
  end
end
