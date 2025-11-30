# frozen_string_literal: true

Apiwork::API.draw '/grumpy-panda' do
  spec :openapi
  spec :zod
  spec :typescript

  resources :orders
end
