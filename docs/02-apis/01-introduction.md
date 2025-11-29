# API Definition

The API definition describes the structure of your API - which resources exist, what actions they support, and how they're organized.

```ruby
Apiwork::API.draw '/api/v1' do
  resources :posts
  resources :comments
end
```

This is similar to Rails' `routes.rb`, but focused on API structure rather than just URL routing.

## Path and Namespace

The path you pass to `draw` determines two things:

1. **Mount point** - where your routes live (`/api/v1/posts`)
2. **Namespace** - where Apiwork looks for controllers and contracts

```ruby
Apiwork::API.draw '/api/v1' do
  resources :posts
end

# Path: /api/v1 ’ Namespace: Api::V1
# Controller: Api::V1::PostsController
# Contract: Api::V1::PostContract
# Schema: Api::V1::PostSchema
```

The conversion is straightforward: `/api/v1` becomes `Api::V1`.

## Root Path

For APIs without a prefix:

```ruby
Apiwork::API.draw '/' do
  resources :posts
end

# Routes at /posts
# No namespace prefix
```

## Multiple APIs

You can define multiple APIs, each completely independent:

```ruby
# config/apis/v1.rb
Apiwork::API.draw '/api/v1' do
  resources :posts, only: [:index, :show]
end

# config/apis/v2.rb
Apiwork::API.draw '/api/v2' do
  resources :posts
  resources :articles
end
```

Each API has its own namespace, controllers, contracts, and generated specs.
