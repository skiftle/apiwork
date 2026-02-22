---
order: 4
---

# Quick Start

This guide builds a Posts API with validation, filtering, sorting, pagination, and exports.

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
  export :openapi
  export :typescript
  export :zod

  resources :posts
end
```

The `export` declarations tell Apiwork to generate documentation at `/.openapi`, `/.typescript`, and `/.zod`.

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

## 4. Representation

The representation defines how posts are serialized and what can be queried:

```ruby
# app/representations/api/v1/post_representation.rb
module Api
  module V1
    class PostRepresentation < ApplicationRepresentation
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

The contract connects to the representation and defines what each action accepts:

```ruby
# app/contracts/api/v1/post_contract.rb
module Api
  module V1
    class PostContract < ApplicationContract
      representation PostRepresentation
    end
  end
end
```

That's it. `representation` connects to `PostRepresentation`. The contract now knows:

- What fields can be written (for create/update)
- What fields can be filtered/sorted (for index)
- The types of all fields (for validation)

## 6. Controller

The controller includes `Apiwork::Controller` and has two differences from standard Rails:

- Use `expose` to return data
- Use `contract.body` for validated params

```ruby
# app/controllers/api/v1/posts_controller.rb
module Api
  module V1
    class PostsController < ApplicationController
      include Apiwork::Controller

      def index
        expose Post.all
      end

      def show
        expose Post.find(params[:id])
      end

      def create
        post = Post.create(contract.body[:post])
        expose post
      end

      def update
        post = Post.find(params[:id])
        post.update(contract.body[:post])
        expose post
      end

      def destroy
        post = Post.find(params[:id])
        post.destroy
        expose post
      end
    end
  end
end
```

::: tip
Requests with undefined fields are rejected. `contract.query` and `contract.body` contain only validated fields.
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

### Get the exports

```bash
curl http://localhost:3000/api/v1/.openapi
curl http://localhost:3000/api/v1/.typescript
curl http://localhost:3000/api/v1/.zod
```

## What You Got

With minimal code, you now have:

1. **Validation** — Requests are validated against your representation before reaching the controller
2. **Serialization** — Responses are automatically formatted using the representation
3. **[Filtering](./adapters/standard-adapter/filtering.md)** — `filterable: true` fields can be filtered via `?filter[field][op]=value`
4. **[Sorting](./adapters/standard-adapter/sorting.md)** — `sortable: true` fields can be sorted via `?sort[field]=asc|desc`
5. **[Pagination](./adapters/standard-adapter/pagination.md)** — Built-in offset-based pagination via `?page[number]=1&page[size]=10`
6. **[Exports](./exports/)** — OpenAPI, TypeScript, and Zod exports generated from the same source

## There's More

This was the simplest possible example. Apiwork also supports:

- **Associations** — sideloading via `?include=comments`
- **Nested writes** — create or update related records in a single request
- **[Includes](./adapters/standard-adapter/includes.md)** — control which associations appear in responses
- **[Advanced filtering](./adapters/standard-adapter/filtering.md)** — operators like `contains`, `starts_with`, and `_and`/`_or` logic
- **[Cursor pagination](./adapters/standard-adapter/pagination.md#cursor-pagination)** — for large datasets
- **Custom types** — enums, unions, and polymorphic associations

## Next Steps

- [Adapters](./adapters/) — filtering, sorting, pagination, and eager loading in depth
- [Contracts](./contracts/) — custom validation and action-specific params
- [Representations](./representations/) — associations, computed attributes, and more
