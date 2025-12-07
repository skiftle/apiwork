# frozen_string_literal: true

Apiwork::API.draw '/gentle_owl' do
  key_format :camel

  spec :openapi
  spec :zod
  spec :typescript

  resources :comments
end
