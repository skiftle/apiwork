# frozen_string_literal: true

module Api
  module V1
    class PostContract < Apiwork::Contract::Base
      schema!

      action :index do
        summary "List all posts"
        description "Returns a paginated list of all posts"
        tags :posts, :public
      end

      action :show do
        summary "Get a post"
        description "Returns a single post by ID"
        raises :not_found, :forbidden
      end

      action :create do
        raises :unprocessable_entity

        request do
          body do
            param :post, type: :object do
              param :title, type: :string
              param :body, type: :string, optional: true
              param :published, type: :boolean, default: false
            end
          end
        end
      end

      action :update do
        raises :not_found, :unprocessable_entity

        request do
          body do
            param :post, type: :object do
              param :title, type: :string, optional: true
              param :body, type: :string, optional: true
              param :published, type: :boolean, optional: true
            end
          end
        end
      end

      # Custom member action - archive post (test deep merge with discriminated union)
      action :archive do
        request do
          body do
            param :reason, type: :string, optional: true
            param :notify_users, type: :boolean, optional: true, default: true
          end
        end

        response do
          body do
            param :archived_at, type: :datetime, optional: true
            param :archive_note, type: :string, optional: true
          end
        end
      end

      # Custom collection action - search posts (test deep merge with collection wrapper)
      action :search do
        request do
          query do
            param :q, type: :string, optional: true, default: ''
          end
        end

        response do
          body do
            param :search_query, type: :string, optional: true
            param :result_count, type: :integer, optional: true
          end
        end
      end

      # Custom collection action - bulk create posts
      action :bulk_create do
        request do
          body do
            param :posts, type: :array, optional: true, default: [] do
              param :title, type: :string
              param :body, type: :string
              param :published, type: :boolean, optional: true, default: false
            end
          end
        end
      end

      # Test replace: true for response (completely replaces schema response)
      # Also tests deprecated and custom operation_id
      action :destroy do
        summary "Delete a post"
        deprecated
        operation_id "deletePost"

        response replace: true do
          body do
            param :deleted_id, type: :uuid
          end
        end
      end
    end
  end
end
