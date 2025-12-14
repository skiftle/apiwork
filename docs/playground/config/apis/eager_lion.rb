# frozen_string_literal: true

Apiwork::API.draw '/eager_lion' do
  key_format :camel

  resources :invoices do
    member do
      patch :archive
    end
  end
end
