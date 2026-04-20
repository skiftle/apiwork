# frozen_string_literal: true

Apiwork::API.define '/sharp_hawk' do
  key_format :camel

  export :openapi
  export :apiwork

  resources :accounts
end
