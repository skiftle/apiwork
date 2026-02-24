# frozen_string_literal: true

Apiwork::API.define '/bright_parrot' do
  key_format :camel

  export :openapi
  export :typescript
  export :zod

  resources :notifications, only: %i[index create]
end
