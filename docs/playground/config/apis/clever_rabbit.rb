# frozen_string_literal: true

Apiwork::API.define '/clever_rabbit' do
  key_format :camel

  export :openapi
  export :apiwork

  resources :orders
end
