# frozen_string_literal: true

Apiwork::API.define '/mighty_wolf' do
  key_format :camel

  resources :vehicles
end
