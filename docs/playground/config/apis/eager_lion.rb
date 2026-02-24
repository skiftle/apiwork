# frozen_string_literal: true

Apiwork::API.define '/eager_lion' do
  key_format :camel

  export :openapi
  export :typescript
  export :zod

  resources :invoices
end
