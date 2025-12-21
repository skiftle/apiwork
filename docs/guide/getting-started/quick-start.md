---
order: 4
---

# Quick Start

Now that you understand the [core concepts](./core-concepts.md), let's put them into practice. We'll build a complete Posts API with validation, filtering, sorting, pagination, and auto-generated specs.

## 1. The Model

Start with a simple Post model:

```bash
rails generate model Post title:string body:text published:boolean
rails db:migrate
```

```ruby
# app/models/post.rb
class Post < ApplicationRecord
  validates :title, presence: true
end
```

## 2. API Definition

Create an API definition that exposes posts as a resource:

```ruby
# config/apis/api_v1.rb
Apiwork::API.define '/api/v1' do
  spec :openapi
  spec :typescript
  spec :zod

  resources :posts
end
```

The `spec` declarations tell Apiwork to generate documentation at `/.spec/openapi`, `/.spec/typescript`, and `/.spec/zod`.

## 3. Routes

Mount Apiwork in your routes:

```ruby
# config/routes.rb
Rails.application.routes.draw do
  mount Apiwork => '/'
end
```

::: info
Apiwork uses the Rails router under the hood. The API definition's path (`/api/v1`) combines with the mount point (`/`) to produce routes like `/api/v1/posts`.
:::

## 4. Schema

The schema defines how posts are serialized and what can be queried:

```ruby
# app/schemas/api/v1/post_schema.rb
module Api
  module V1
    class PostSchema < ApplicationSchema
      attribute :id
      attribute :title, writable: true, filterable: true
      attribute :body, writable: true
      attribute :published, writable: true, filterable: true
      attribute :created_at, sortable: true
      attribute :updated_at, sortable: true
    end
  end
end
```

Each option does one thing:

- `writable: true` — the field can be set in create/update requests
- `filterable: true` — the field can be filtered via query params
- `sortable: true` — the field can be sorted via query params

Types, nullability, and defaults are auto-detected from your database columns.

## 5. Contract

The contract pulls in the schema and defines what each action accepts:

```ruby
# app/contracts/api/v1/post_contract.rb
module Api
  module V1
    class PostContract < ApplicationContract
      schema!
    end
  end
end
```

That's it. `schema!` imports everything from `PostSchema`. The contract now knows:

- What fields can be written (for create/update)
- What fields can be filtered/sorted (for index)
- The types of all fields (for validation)

## 6. Controller

The controller looks like any Rails controller, with two differences: use `respond` instead of `render`, and access validated params via `contract.query` (URL params) and `contract.body` (request body):

```ruby
# app/controllers/api/v1/posts_controller.rb
module Api
  module V1
    class PostsController < ApplicationController
      include Apiwork::Controller

      def index
        respond Post.all
      end

      def show
        respond Post.find(params[:id])
      end

      def create
        post = Post.create(contract.body[:post])
        respond post
      end

      def update
        post = Post.find(params[:id])
        post.update(contract.body[:post])
        respond post
      end

      def destroy
        post = Post.find(params[:id])
        post.destroy
        respond post
      end
    end
  end
end
```

::: tip
`contract.query` and `contract.body` replace Strong Parameters. They contain only the fields defined in your schema — unknown fields are filtered out before your controller runs.
:::

## 7. Try It

Start the server:

```bash
rails server
```

### Create a post

```bash
curl -X POST http://localhost:3000/api/v1/posts \
  -H "Content-Type: application/json" \
  -d '{"post": {"title": "Hello World", "body": "My first post", "published": true}}'
```

### List posts

```bash
curl http://localhost:3000/api/v1/posts
```

### Filter and sort

```bash
# Only published posts
curl "http://localhost:3000/api/v1/posts?filter[published][eq]=true"

# Sort by newest first
curl "http://localhost:3000/api/v1/posts?sort[created_at]=desc"

# Paginate
curl "http://localhost:3000/api/v1/posts?page[number]=1&page[size]=10"
```

### Get the specs

```bash
curl http://localhost:3000/api/v1/.spec/openapi
curl http://localhost:3000/api/v1/.spec/typescript
curl http://localhost:3000/api/v1/.spec/zod
```

## What You Got

With minimal code, you now have:

1. **Validation** — Requests are validated against your schema before reaching the controller
2. **Serialization** — Responses are automatically formatted using the schema
3. **Filtering** — `filterable: true` fields can be filtered via `?filter[field][op]=value`
4. **Sorting** — `sortable: true` fields can be sorted via `?sort[field]=asc|desc`
5. **Pagination** — Built-in offset-based pagination via `?page[number]=1&page[size]=10`
6. **Documentation** — OpenAPI, TypeScript, and Zod specs generated from the same source

## There's More

This was the simplest possible example. Apiwork also supports:

- **Associations** — sideloading via `?include=comments`
- **Nested writes** — create or update related records in a single request
- **[Eager loading](../core/execution-engine/eager-loading.md)** — automatic N+1 prevention
- **[Advanced filtering](../core/execution-engine/filtering.md)** — operators like `contains`, `starts_with`, and `_and`/`_or` logic
- **[Cursor pagination](../core/execution-engine/pagination.md#cursor-pagination)** — for large datasets
- **Custom types** — enums, unions, and polymorphic associations

## Next Steps

- [Execution Engine](../core/execution-engine/introduction.md) — filtering, sorting, pagination, and eager loading in depth
- [Contracts](../core/contracts/introduction.md) — custom validation and action-specific params
- [Schemas](../core/schemas/introduction.md) — associations, computed attributes, and more
