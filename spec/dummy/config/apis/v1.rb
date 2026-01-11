# frozen_string_literal: true

Apiwork::API.define '/api/v1' do
  export :openapi
  export :zod
  export :typescript

  # Global errors that all endpoints can raise
  raises :bad_request, :internal_server_error

  info do
    title 'Test API'
    version '1.0.0'
    summary 'A test API for Apiwork'
    description 'Dummy API for the Apiwork gem'
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

  # API-level key format
  key_format :keep

  # API-level adapter configuration
  adapter do
    pagination do
      default_size 20
      max_size 200
    end
  end

  # API-level types - available to all contracts in this API
  # Error response type
  object :error_detail do
    string :code
    string :message
    string :field
  end

  # Sorting enums
  enum :sort_direction, values: %i[asc desc]
  enum :post_status, values: %i[draft published archived]

  # Pagination type
  object :pagination_params do
    integer :page
    integer :per_page
  end

  resources :posts do
    member do
      patch :publish
      patch :archive
      get :preview
    end

    collection do
      get :search
      post :bulk_create
    end

    # Nested resources
    resources :comments do
      member do
        patch :approve
      end

      collection do
        get :recent
      end
    end
  end

  # Top-level comments (non-nested)
  resources :comments

  # Alternative resource representation for same Post model
  # ArticlesController uses ArticleResource which only exposes id + title
  resources :articles

  # Demonstrates irregular plural root keys (person/people)
  # PersonsController uses PersonResource with root :person, :people
  resources :persons

  # Routing DSL override testing - restrict available actions
  resources :restricted_posts, only: [:index, :show]

  # Routing DSL override testing - exclude specific actions
  resources :safe_comments, except: [:destroy]

  # Account resource for testing enum validation and filterable enum attributes
  resources :accounts, only: [:index, :show]

  # Camelized account resource for testing enum validation with key transformation
  resources :camelized_accounts, only: [:show]

  # User resource for testing empty and other attribute transformations
  resources :users

  # Author resource for testing writable context filtering (on: [:create], on: [:update])
  resources :authors

  # Client resource for testing STI (Single Table Inheritance)
  resources :clients

  # Service resource for testing associations with STI
  resources :services

  # Activity resource for testing cursor-based pagination
  resources :activities

  # Singular resource for testing profile without :id in URL
  resource :profile
end
