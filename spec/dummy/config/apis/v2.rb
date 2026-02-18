# frozen_string_literal: true

Apiwork::API.define '/api/v2' do
  key_format :camel
  path_format :kebab

  export :openapi
  export :typescript

  info do
    title 'Billing API V2'
    version '2.0.0'
    description 'API with kebab-case paths'
  end

  resources :customer_addresses
end
