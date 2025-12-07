# frozen_string_literal: true

Apiwork::API.draw '/swift_fox' do
  key_format :camel

  resources :contacts
end
