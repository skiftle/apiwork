# frozen_string_literal: true

module Api
  module V1
    class PostContract < Apiwork::Contract::Base
      schema!

      action :show do
        error_codes 404, 403 # Not found, forbidden
      end

      action :create do
        error_codes 422 # Validation error

        request do
          body do
            param :post, type: :object, required: true do
              param :title, type: :string
              param :body, type: :string, required: false
              param :published, type: :boolean, default: false
            end
          end
        end
      end

      action :update do
        error_codes 404, 422 # Not found, validation error

        request do
          body do
            param :post, type: :object, required: true do
              param :title, type: :string, required: false
              param :body, type: :string, required: false
              param :published, type: :boolean, required: false
            end
          end
        end
      end

      # Custom member action - archive post (test deep merge with discriminated union)
      action :archive do
        request do
          body do
            param :reason, type: :string, required: false
            param :notify_users, type: :boolean, required: false, default: true
          end
        end

        response do
          body do
            param :archived_at, type: :datetime, required: false
            param :archive_note, type: :string, required: false
          end
        end
      end

      # Custom collection action - search posts (test deep merge with collection wrapper)
      action :search do
        request do
          query do
            param :q, type: :string
          end
        end

        response do
          body do
            param :search_query, type: :string, required: false
            param :result_count, type: :integer, required: false
          end
        end
      end

      # Custom collection action - bulk create posts
      action :bulk_create do
        request do
          body do
            param :posts, type: :array, required: false, default: [] do
              param :title, type: :string
              param :body, type: :string
              param :published, type: :boolean
            end
          end
        end
      end

      # Test replace: true for response (completely replaces schema response)
      action :destroy do
        response replace: true do
          body do
            param :deleted_id, type: :uuid, required: true
          end
        end
      end
    end
  end
end
