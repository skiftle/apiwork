---
order: 1
---

# Introduction

The API definition describes the overall shape of your API — which resources exist, which actions they offer and how everything is organised. It also serves as the configuration point for that specific API. Here you decide the key format, which specifications should be generated, which adapter to use and any options that control how the API behaves. These settings are defined at the API level rather than globally. This is intentional: API versioning is common in Rails applications, and different versions may require different behaviour. By keeping the configuration inside each API definition, Apiwork allows every version to define its own rules without affecting the others.

```ruby
Apiwork::API.define '/api/v1' do
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
Apiwork::API.define '/api/v1' do
  resources :posts
end

# Path: /api/v1 → Namespace: Api::V1
# Controller: Api::V1::PostsController
# Contract: Api::V1::PostContract
# Schema: Api::V1::PostSchema
```

The conversion is straightforward: `/api/v1` becomes `Api::V1`.

## Root Path

For APIs without a prefix:

```ruby
Apiwork::API.define '/' do
  resources :posts
end

# Routes at /posts
# No namespace prefix
```

## Multiple APIs

You can define multiple APIs, each completely independent:

```ruby
# config/apis/api_v1.rb
Apiwork::API.define '/api/v1' do
  resources :posts, only: [:index, :show]
end

# config/apis/api_v2.rb
Apiwork::API.define '/api/v2' do
  resources :posts
  resources :articles
end
```

Each API has its own namespace, controllers, contracts, and generated specs.
