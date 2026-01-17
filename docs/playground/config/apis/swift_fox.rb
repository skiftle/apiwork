# frozen_string_literal: true

Apiwork::API.define '/swift_fox' do
  key_format :camel

  export :openapi
  export :typescript
  export :zod

  resources :contacts
end
