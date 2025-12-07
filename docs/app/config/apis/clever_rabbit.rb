# frozen_string_literal: true

Apiwork::API.draw '/clever_rabbit' do
  key_format :camel

  resources :orders
end
