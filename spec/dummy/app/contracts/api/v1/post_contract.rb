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
            object :post do
              string :title
              string :body, optional: true
              boolean :published, default: false
            end
          end
        end
      end

      action :update do
        raises :not_found, :unprocessable_entity

        request do
          body do
            object :post do
              string :title, optional: true
              string :body, optional: true
              boolean :published, optional: true
            end
          end
        end
      end

      # Custom member action - archive post (test deep merge with discriminated union)
      action :archive do
        request do
          body do
            string :reason, optional: true
            boolean :notify_users, optional: true, default: true
          end
        end

        response do
          body do
            datetime :archived_at, optional: true
            string :archive_note, optional: true
          end
        end
      end

      # Custom collection action - search posts (test deep merge with collection wrapper)
      action :search do
        request do
          query do
            string :q, optional: true, default: ''
          end
        end

        response do
          body do
            string :search_query, optional: true
            integer :result_count, optional: true
          end
        end
      end

      # Custom collection action - bulk create posts
      action :bulk_create do
        request do
          body do
            array :posts, optional: true, default: [] do
              object do
                string :title
                string :body
                boolean :published, optional: true, default: false
              end
            end
          end
        end
      end

      # Test replace: true for response (completely replaces schema response)
      # Also tests deprecated and custom operation_id
      action :destroy do
        summary "Delete a post"
        deprecated!
        operation_id "deletePost"

        response replace: true do
          body do
            uuid :deleted_id
          end
        end
      end
    end
  end
end
