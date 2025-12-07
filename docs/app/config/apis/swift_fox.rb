# frozen_string_literal: true

Apiwork::API.draw '/swift-fox' do
  spec :openapi
  spec :zod
  spec :typescript

  resources :contacts
end
