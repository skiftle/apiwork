# frozen_string_literal: true

Apiwork::API.define '/curious_cat' do
  key_format :camel
  resources :profiles
end
