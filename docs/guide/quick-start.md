---
order: 4
---

# Quick Start

This guide builds a Posts API with validation, filtering, sorting, pagination, and exports.

## 1. The Model

The API starts with a simple Post model:

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

The API definition exposes posts as a resource:

```ruby
# config/apis/api_v1.rb
Apiwork::API.define '/api/v1' do
  export :openapi
  export :typescript
  export :zod
  export :sorbus

  resources :posts
end
```

The `export` declarations tell Apiwork to generate exports at `/.openapi`, `/.typescript`, `/.zod`, and `/.sorbus`.

## 3. Routes

Apiwork is mounted in the routes:

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

- `writable: true` — the attribute can be set in create/update requests
- `filterable: true` — the attribute can be filtered via query parameters
- `sortable: true` — the attribute can be sorted via query parameters

Types, nullability, and defaults are auto-detected from the database columns.

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

`representation` connects to `PostRepresentation`. The contract now knows:

- What attributes can be written (for create/update)
- What attributes can be filtered/sorted (for index)
- The types of all attributes (for validation)

## 6. Controller

The controller includes `Apiwork::Controller` and has two differences from standard Rails:

- `expose` returns data
- `contract.body` provides validated params

```ruby
# app/controllers/api/v1/posts_controller.rb
module Api
  module V1
    class PostsController < ApplicationController
      include Apiwork::Controller

      before_action :set_post, only: %i[show update destroy]

      def index
        expose Post.all
      end

      def show
        expose post
      end

      def create
        post = Post.create(contract.body[:post])
        expose post
      end

      def update
        post.update(contract.body[:post])
        expose post
      end

      def destroy
        post.destroy
        expose post
      end

      private

      attr_reader :post

      def set_post
        @post = Post.find(params[:id])
      end
    end
  end
end
```

::: tip
Requests with undefined params are rejected. `contract.query` and `contract.body` contain only validated params.
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
curl http://localhost:3000/api/v1/.sorbus
```

## What You Got

The application now has:

1. **Validation** — Requests are validated against the representation before reaching the controller
2. **Serialization** — Responses are automatically formatted using the representation
3. **[Filtering](./adapters/standard-adapter/filtering.md)** — `filterable: true` attributes can be filtered via `?filter[field][op]=value`
4. **[Sorting](./adapters/standard-adapter/sorting.md)** — `sortable: true` attributes can be sorted via `?sort[field]=asc|desc`
5. **[Pagination](./adapters/standard-adapter/pagination.md)** — Built-in offset-based pagination via `?page[number]=1&page[size]=10`
6. **[Exports](./exports/)** — OpenAPI, TypeScript, Zod, and [Sorbus](./exports/sorbus.md) exports generated from the same source

## Additional Features

The quick start covered the basics. Other features include:

- **Associations** — eager loading via `?include[comments]=true`
- **Nested writes** — create or update related records in a single request
- **[Includes](./adapters/standard-adapter/includes.md)** — control which associations appear in responses
- **[Advanced filtering](./adapters/standard-adapter/filtering.md)** — operators like `contains`, `starts_with`, and `AND`/`OR` logic
- **[Cursor pagination](./adapters/standard-adapter/pagination.md#cursor-based-pagination)** — for large datasets
- **Custom types** — enums, unions, and polymorphic associations

## Next Steps

- [Adapters](./adapters/) — filtering, sorting, pagination, and eager loading in depth
- [Contracts](./contracts/) — custom validation and action-specific params
- [Representations](./representations/) — associations, computed attributes, and more
