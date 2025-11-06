# frozen_string_literal: true

module Api
  module V1
    # ArticlesContract - Minimal input contract for Article resources
    # Demonstrates how contracts can define minimal input requirements
    # while the underlying model may have additional fields
    class ArticlesContract < Apiwork::Contract::Base
      schema 'Api::V1::ArticleSchema'

      # Standard CRUD actions - only require title
      # Auto-wrapping in :article happens automatically with reset_input!
      action :create do
        reset_input!
        input do
          param :title, type: :string
        end
      end

      action :update do
        reset_input!
        input do
          param :title, type: :string
        end
      end

      # Note: show, index, destroy use default behavior
      # and serialize through ArticleSchema
    end
  end
end
