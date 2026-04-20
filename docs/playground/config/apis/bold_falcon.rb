# frozen_string_literal: true

Apiwork::API.define '/bold_falcon' do
  key_format :camel

  export :openapi
  export :apiwork

  resources :articles
end
