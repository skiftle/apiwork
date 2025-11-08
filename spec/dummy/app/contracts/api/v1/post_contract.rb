# frozen_string_literal: true

module Api
  module V1
    class PostContract < Apiwork::Contract::Base
      schema PostSchema

      action :show do
        error_codes 404, 403  # Not found, forbidden
      end

      action :create do
        error_codes 422  # Validation error

        input do
          param :title, type: :string
          param :body, type: :string, required: false
          param :published, type: :boolean, default: false
        end
      end

      action :update do
        error_codes 404, 422  # Not found, validation error

        input do
          param :title, type: :string, required: false
          param :body, type: :string, required: false
          param :published, type: :boolean, required: false
        end
      end

      # Custom collection action - search posts
      action :search do
        input do
          param :q, type: :string
        end
      end

      # Custom collection action - bulk create posts
      action :bulk_create do
        input do
          param :posts, type: :array do
            param :title, type: :string
            param :body, type: :string
            param :published, type: :boolean
          end
        end
      end
    end
  end
end
