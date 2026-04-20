# frozen_string_literal: true

Apiwork::API.define '/loyal_hound' do
  key_format :camel

  export :openapi
  export :apiwork

  resources :books
end
