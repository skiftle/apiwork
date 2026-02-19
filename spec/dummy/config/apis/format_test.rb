# frozen_string_literal: true

Apiwork::API.define '/api/format-test' do
  key_format :camel
  path_format :kebab

  export :openapi
  export :typescript

  info do
    title 'Format Test API'
    version '1.0.0'
    description 'API testing camelCase keys and kebab-case paths'
  end

  resources :customer_addresses
end
