# frozen_string_literal: true

Apiwork::API.define '/calm_turtle' do
  key_format :camel

  export :openapi
  export :typescript
  export :zod

  resources :customers
  resources :orders
end
