# frozen_string_literal: true

Apiwork::API.draw '/gentle-owl' do
  spec :openapi
  spec :zod
  spec :typescript

  resources :comments
end
