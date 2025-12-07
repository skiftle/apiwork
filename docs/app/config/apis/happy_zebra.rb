# frozen_string_literal: true

Apiwork::API.draw '/happy-zebra' do
  spec :openapi
  spec :zod
  spec :typescript

  resources :users
  resources :posts
  resources :comments
end
