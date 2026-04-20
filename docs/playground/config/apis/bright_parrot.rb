# frozen_string_literal: true

Apiwork::API.define '/bright_parrot' do
  key_format :camel

  export :openapi
  export :apiwork

  resources :notifications, only: %i[index create]
end
