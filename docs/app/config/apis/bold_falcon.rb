# frozen_string_literal: true

Apiwork::API.draw '/bold_falcon' do
  key_format :camel

  spec :openapi
  spec :zod
  spec :typescript

  resources :articles
end
