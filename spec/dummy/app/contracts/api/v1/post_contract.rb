# frozen_string_literal: true

module Api
  module V1
    class PostContract < Apiwork::Contract::Base
      resource PostResource

      action :create do
        input do
          param :title, type: :string
          param :body, type: :string, required: false
          param :published, type: :boolean, default: false
        end
      end

      action :update do
        input do
          param :title, type: :string, required: false
          param :body, type: :string, required: false
          param :published, type: :boolean, required: false
        end
      end
    end
  end
end
