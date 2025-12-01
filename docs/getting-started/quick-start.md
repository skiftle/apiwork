---
order: 5
---

# Quick Start

This guide walks you through building a complete API endpoint with validation, serialization, filtering, and documentation.

## The Goal

We'll create a Posts API with:
- List posts with filtering and pagination
- Create posts with validation
- Auto-generated OpenAPI spec

## 1. Database Setup

```ruby
# db/migrate/xxx_create_posts.rb
class CreatePosts < ActiveRecord::Migration[8.0]
  def change
    create_table :posts do |t|
      t.string :title, null: false
      t.text :body
      t.string :status, default: 'draft'
      t.timestamps
    end
  end
end
```

```ruby
# app/models/post.rb
class Post < ApplicationRecord
  enum :status, { draft: 'draft', published: 'published', archived: 'archived' }

  validates :title, presence: true
end
```

## 2. API Definition

```ruby
# config/apis/v1.rb
Apiwork::API.draw '/api/v1' do
  resources :posts

  spec :openapi
  spec :typescript
end
```

## 3. Schema

The schema defines how your model is serialized and what can be filtered/sorted:

```ruby
# app/schemas/api/v1/post_schema.rb
class Api::V1::PostSchema < Apiwork::Schema::Base
  attribute :id
  attribute :title, writable: true, filterable: true
  attribute :body, writable: true
  attribute :status, writable: true, filterable: true, sortable: true
  attribute :created_at, sortable: true
  attribute :updated_at
end
```

## 4. Contract

The contract imports the schema and can add action-specific rules:

```ruby
# app/contracts/api/v1/post_contract.rb
class Api::V1::PostContract < Apiwork::Contract::Base
  schema!
end
```

`schema!` imports all attributes from PostSchema. The contract now knows:
- What fields are writable (for create/update)
- What fields are filterable/sortable (for index)
- The types of all fields (for validation)

## 5. Controller

```ruby
# app/controllers/api/v1/posts_controller.rb
class Api::V1::PostsController < ApplicationController
  include Apiwork::Controller::Concern

  def index
    respond_with Post.all
  end

  def show
    respond_with Post.find(params[:id])
  end

  def create
    post = Post.create!(contract.body[:post])
    respond_with post, status: :created
  end

  def update
    post = Post.find(params[:id])
    post.update!(contract.body[:post])
    respond_with post
  end

  def destroy
    post = Post.find(params[:id])
    post.destroy!
    head :no_content
  end
end
```

## 6. Try It Out

Start the server:

```bash
rails server
```

### Create a post

```bash
curl -X POST http://localhost:3000/api/v1/posts \
  -H "Content-Type: application/json" \
  -d '{"post": {"title": "Hello World", "body": "My first post"}}'
```

### List posts with filtering

```bash
# All posts
curl http://localhost:3000/api/v1/posts

# Filter by status
curl "http://localhost:3000/api/v1/posts?filter[status][eq]=published"

# Sort by created_at descending
curl "http://localhost:3000/api/v1/posts?sort[created_at]=desc"

# Paginate
curl "http://localhost:3000/api/v1/posts?page[number]=1&page[size]=10"
```

### Get the OpenAPI spec

```bash
curl http://localhost:3000/api/v1/.spec/openapi
```

## What Just Happened?

With minimal code, you got:

1. **Validation** — The contract validates incoming data matches the schema types
2. **Serialization** — Responses are automatically formatted using the schema
3. **Filtering** — `filterable: true` attributes can be filtered via query params
4. **Sorting** — `sortable: true` attributes can be sorted
5. **Pagination** — Built-in page-based pagination
6. **Documentation** — OpenAPI spec generated from your contracts and schemas

## Next Steps

- [Contracts](../core/contracts/introduction.md) — Add custom validation and action-specific params
- [Schemas](../core/schemas/introduction.md) — Associations, computed attributes, and more
- [Spec Generation](../core/spec-generation/introduction.md) — TypeScript, Zod, and OpenAPI options
