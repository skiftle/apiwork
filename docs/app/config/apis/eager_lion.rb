# frozen_string_literal: true

Apiwork::API.draw '/eager-lion' do
  spec :openapi
  spec :zod
  spec :typescript

  resources :invoices do
    member do
      patch :archive
    end
  end
end
