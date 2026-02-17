# frozen_string_literal: true

Apiwork::API.define '/api/v2' do
  export :openapi
  export :typescript

  info do
    title 'Billing API V2'
    version '2.0.0'
    description 'API with kebab-case paths'
  end

  key_format :camel
  path_format :kebab

  resources :customer_addresses
end
