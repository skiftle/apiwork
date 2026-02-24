# frozen_string_literal: true

Apiwork::API.define '/gentle_owl' do
  key_format :camel

  export :openapi
  export :typescript
  export :zod

  resources :comments
end
