# frozen_string_literal: true

Apiwork::API.draw '/mighty-wolf' do
  spec :openapi
  spec :zod
  spec :typescript

  resources :vehicles
end
