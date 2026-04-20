# frozen_string_literal: true

Apiwork::API.define '/nimble_gecko' do
  key_format :pascal
  path_format :kebab

  export :openapi
  export :apiwork

  resources :meal_plans
end
