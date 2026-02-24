# frozen_string_literal: true

Apiwork::API.define '/mighty_wolf' do
  key_format :camel

  export :openapi
  export :typescript
  export :zod

  resources :vehicles
end
