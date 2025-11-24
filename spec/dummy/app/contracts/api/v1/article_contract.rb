# frozen_string_literal: true

module Api
  module V1
    # ArticleContract - Minimal request contract for Article resources
    # Demonstrates how contracts can define minimal request requirements
    # while the underlying model may have additional fields
    class ArticleContract < Apiwork::Contract::Base
      schema!

      # Standard CRUD actions - only require title
      # When using replace: true, we must manually wrap in root key
      action :create do
        request replace: true do
          body do
            param :article, type: :object, required: true do
              param :title, type: :string
            end
          end
        end
      end

      action :update do
        request replace: true do
          body do
            param :article, type: :object, required: true do
              param :title, type: :string
            end
          end
        end
      end

      # Note: show, index, destroy use default behavior
      # and serialize through ArticleSchema
    end
  end
end
