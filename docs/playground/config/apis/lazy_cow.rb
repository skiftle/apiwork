# frozen_string_literal: true

Apiwork::API.define '/lazy_cow' do
  key_format :camel

  export :openapi
  export :typescript
  export :zod

  resource :status, only: [] do
    collection do
      get :health
      get :stats
    end
  end
end
