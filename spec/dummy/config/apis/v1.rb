# frozen_string_literal: true

Apiwork::API.draw '/api/v1' do
  schema :openapi
  schema :transport

  doc do
    title 'Test API'
    version '1.0.0'
    description 'Test API for Apiwork gem'
  end

  resources :posts
  resources :comments
end
