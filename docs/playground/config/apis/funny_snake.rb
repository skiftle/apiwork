# frozen_string_literal: true

Apiwork::API.define '/funny_snake' do
  key_format :camel

  export :openapi
  export :typescript
  export :zod

  resources :invoices
end
