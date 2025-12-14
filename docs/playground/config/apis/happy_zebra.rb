# frozen_string_literal: true

Apiwork::API.draw '/happy_zebra' do
  key_format :camel

  resources :users
  resources :posts
  resources :comments
end
