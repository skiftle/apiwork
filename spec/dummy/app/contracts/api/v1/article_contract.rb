# frozen_string_literal: true

module Api
  module V1
    class ArticleContract < Apiwork::Contract::Base
      representation ArticleRepresentation

      action :create do
        request replace: true do
          body do
            object :article do
              string :title
            end
          end
        end
      end

      action :update do
        request replace: true do
          body do
            object :article do
              string :title
            end
          end
        end
      end
    end
  end
end
