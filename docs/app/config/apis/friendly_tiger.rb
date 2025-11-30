# frozen_string_literal: true

Apiwork::API.draw '/friendly-tiger' do
  spec :openapi
  spec :zod
  spec :typescript

  resources :orders
end
