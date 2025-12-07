# frozen_string_literal: true

Apiwork::API.draw '/mighty_wolf' do
  key_format :camel

  spec :openapi
  spec :zod
  spec :typescript

  resources :vehicles
end
