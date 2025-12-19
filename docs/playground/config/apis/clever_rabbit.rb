# frozen_string_literal: true

Apiwork::API.define '/clever_rabbit' do
  key_format :camel

  resources :orders
end
