# frozen_string_literal: true

Apiwork::API.define '/api/v1' do
  key_format :keep

  export :openapi
  export :typescript
  export :zod

  info do
    title 'Billing API'
    version '1.0.0'
    summary 'A billing API for Apiwork'
    description 'Dummy billing API for the Apiwork gem'
    terms_of_service 'https://example.com/terms'

    contact do
      name 'API Support'
      email 'support@example.com'
      url 'https://example.com/support'
    end

    license do
      name 'MIT'
      url 'https://opensource.org/licenses/MIT'
    end

    server do
      url 'https://api.example.com'
      description 'Production'
    end
    server do
      url 'https://staging-api.example.com'
      description 'Staging'
    end
  end

  raises :bad_request, :internal_server_error

  adapter do
    pagination do
      default_size 20
      max_size 200
    end
  end

  object :error_detail do
    string :code
    string :message
    string :field
  end

  enum :sort_direction, values: %i[asc desc]
  enum :status, values: %i[draft sent paid overdue void]
  enum :method, values: %i[credit_card bank_transfer cash]

  object :pagination_params do
    integer :page
    integer :per_page
  end

  resources :invoices do
    member do
      patch :send_invoice
      patch :void
    end

    collection do
      get :search
      post :bulk_create
    end

    resources :items
  end

  resources :items

  resources :customers

  resources :payments

  resources :services

  resources :activities

  resources :receipts

  resources :restricted_invoices, only: [:index, :show]

  resources :safe_items, except: [:destroy]

  resource :profile
end
