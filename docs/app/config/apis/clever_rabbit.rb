# frozen_string_literal: true

Apiwork::API.draw '/clever_rabbit' do
  key_format :camel

  spec :openapi
  spec :zod
  spec :typescript

  resources :orders
end
