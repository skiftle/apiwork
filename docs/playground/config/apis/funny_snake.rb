# frozen_string_literal: true

Apiwork::API.define '/funny_snake' do
  key_format :camel

  resources :invoices
end
