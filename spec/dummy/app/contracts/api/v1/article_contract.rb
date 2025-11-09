# frozen_string_literal: true

module Api
  module V1
    # ArticleContract - Minimal input contract for Article resources
    # Demonstrates how contracts can define minimal input requirements
    # while the underlying model may have additional fields
    class ArticleContract < Apiwork::Contract::Base
      schema ArticleSchema

      # Standard CRUD actions - only require title
      # Auto-wrapping in :article happens automatically with input replace: true
      action :create do
        input replace: true do
          param :title, type: :string
        end
      end

      action :update do
        input replace: true do
          param :title, type: :string
        end
      end

      # Note: show, index, destroy use default behavior
      # and serialize through ArticleSchema
    end
  end
end
