# frozen_string_literal: true

Apiwork::API.draw '/swift-fox' do
  key_format :camel

  spec :openapi
  spec :zod
  spec :typescript

  resources :posts
end
