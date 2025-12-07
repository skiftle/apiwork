# frozen_string_literal: true

Apiwork::API.draw '/lazy-cow' do
  key_format :camel

  spec :openapi
  spec :zod
  spec :typescript

  resource :status, only: [] do
    collection do
      get :health
      get :stats
    end
  end
end
