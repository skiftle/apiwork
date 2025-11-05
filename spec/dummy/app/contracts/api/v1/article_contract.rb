# frozen_string_literal: true

module Api
  module V1
    # ArticleContract - Minimal input contract for Article resources
    # Demonstrates how contracts can define minimal input requirements
    # while the underlying model may have additional fields
    class ArticleContract < Apiwork::Contract::Base
      resource Api::V1::ArticleResource

      # Standard CRUD actions - only require title
      action :create do
        reset_input!
        input do
          param :article, type: :object, required: true do
            param :title, type: :string
          end
        end
      end

      action :update do
        reset_input!
        input do
          param :article, type: :object, required: true do
            param :title, type: :string
          end
        end
      end

      # Note: show, index, destroy use default behavior
      # and serialize through ArticleResource
    end
  end
end
