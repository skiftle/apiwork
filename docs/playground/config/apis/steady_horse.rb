# frozen_string_literal: true

Apiwork::API.define '/steady_horse' do
  key_format :camel

  export :openapi
  export :typescript
  export :zod

  resources :products
end
