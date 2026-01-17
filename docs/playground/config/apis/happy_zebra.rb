# frozen_string_literal: true

Apiwork::API.define '/happy_zebra' do
  key_format :camel

  export :openapi
  export :typescript
  export :zod

  resources :users
  resources :posts
  resources :comments
end
