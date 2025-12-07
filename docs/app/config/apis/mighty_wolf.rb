# frozen_string_literal: true

Apiwork::API.draw '/mighty-wolf' do
  key_format :camel

  spec :openapi
  spec :zod
  spec :typescript

  resources :vehicles
end
