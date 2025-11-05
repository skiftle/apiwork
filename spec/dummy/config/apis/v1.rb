# frozen_string_literal: true

Apiwork::API.draw '/api/v1' do
  schema :openapi
  schema :transport

  doc do
    title 'Test API'
    version '1.0.0'
    description 'Test API for Apiwork gem'
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
end
