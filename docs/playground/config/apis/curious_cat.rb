# frozen_string_literal: true

Apiwork::API.define '/curious_cat' do
  key_format :camel

  export :openapi
  export :typescript
  export :zod

  resources :profiles
end
