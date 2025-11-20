# frozen_string_literal: true

Apiwork::API.draw '/api/v1' do
  spec :openapi
  spec :zod
  spec :typescript

  # Global error codes for all endpoints
  error_codes 400, 500

  info do
    title 'Test API'
    version '1.0.0'
    description 'Dummy API for the Apiwork gem'
  end

  # API-level configuration
  configure do
    output_key_format :keep
    input_key_format :keep
    default_sort id: :asc
    default_page_size 20
    max_page_size 200
    max_array_items 1000
  end

  # API-level descriptors - available to all contracts in this API
  descriptors do
    # Error response type
    type :error_detail do
      param :code, type: :string
      param :message, type: :string
      param :field, type: :string
    end

    # Sorting enums
    enum :sort_direction, %i[asc desc]
    enum :post_status, %i[draft published archived]

    # Pagination type
    type :pagination_params do
      param :page, type: :integer
      param :per_page, type: :integer
    end
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

  # Account resource for testing enum validation
  resources :accounts, only: [:show]

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
end
