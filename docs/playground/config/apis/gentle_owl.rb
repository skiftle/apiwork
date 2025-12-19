# frozen_string_literal: true

Apiwork::API.define '/gentle_owl' do
  key_format :camel

  resources :comments
end
