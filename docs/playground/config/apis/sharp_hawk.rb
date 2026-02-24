# frozen_string_literal: true

Apiwork::API.define '/sharp_hawk' do
  key_format :camel

  export :openapi
  export :typescript
  export :zod

  resources :accounts
end
