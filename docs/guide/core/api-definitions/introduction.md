---
order: 1
---

# Introduction

The API definition describes the shape of your API:

- Which [resources](./resources.md) exist
- Which actions they offer
- How everything is organized

It's also where you configure API-specific settings:

- Key format (camelCase, snake_case)
- Which [exports](./exports.md) to generate
- Adapter options
- Global types and enums

```ruby
# config/apis/api_v1.rb
Apiwork::API.define '/api/v1' do
  resources :posts
  resources :comments
end
```

::: info
Each API definition is independent. Different API versions can have different configurations without affecting each other.
:::

## Path and Namespace

The path you pass to `define` determines two things:

1. **Mount point** - where your routes live (`/api/v1/posts`)
2. **Namespace** - where Apiwork looks for controllers and contracts

```ruby
Apiwork::API.define '/api/v1' do
  resources :posts
end

# Path: /api/v1 maps to namespace Api::V1
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

Each API has its own namespace with controllers, contracts, and schemas.

#### See also

- [API::Base reference](../../../reference/api-base.md) — all API definition methods and options
