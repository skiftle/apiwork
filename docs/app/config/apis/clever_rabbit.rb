# frozen_string_literal: true

Apiwork::API.draw '/clever-rabbit' do
  spec :openapi
  spec :zod
  spec :typescript

  resources :orders
end
