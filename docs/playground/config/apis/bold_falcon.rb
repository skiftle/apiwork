# frozen_string_literal: true

Apiwork::API.draw '/bold_falcon' do
  key_format :camel

  resources :articles
end
