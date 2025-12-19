# frozen_string_literal: true

Apiwork::API.define '/bold_falcon' do
  key_format :camel

  resources :articles
end
