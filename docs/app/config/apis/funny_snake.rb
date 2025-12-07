# frozen_string_literal: true

Apiwork::API.draw '/funny-snake' do
  key_format :camel

  resources :invoices
end
