# frozen_string_literal: true

Apiwork::API.draw '/mighty_wolf' do
  key_format :camel

  resources :vehicles
end
