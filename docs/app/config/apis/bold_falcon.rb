# frozen_string_literal: true

Apiwork::API.draw '/bold-falcon' do
  spec :openapi
  spec :zod
  spec :typescript

  resources :articles
end
