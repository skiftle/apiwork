# frozen_string_literal: true

Apiwork::API.define '/wise_tiger' do
  key_format :camel

  export :openapi
  export :typescript
  export :zod

  info do
    version '1.0.0'
  end

  resources :projects
end
