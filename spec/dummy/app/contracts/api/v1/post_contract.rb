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

      # Custom member action - archive post (test deep merge with discriminated union)
      action :archive do
        input do
          param :reason, type: :string, required: false
          param :notify_users, type: :boolean, required: false, default: true
        end

        output do
          param :archived_at, type: :datetime, required: false
          param :archive_note, type: :string, required: false
        end
      end

      # Custom collection action - search posts (test deep merge with collection wrapper)
      action :search do
        input do
          param :q, type: :string
        end

        output do
          param :search_query, type: :string, required: false
          param :result_count, type: :integer, required: false
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

      # Override destroy to test output replace: true (complete replacement, no discriminated union)
      action :destroy do
        output replace: true do
          param :deleted_id, type: :uuid, required: true
        end
      end
    end
  end
end
