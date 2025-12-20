---
order: 4
---

# Core Concepts

Apiwork is built around three main pieces: **API definitions**, **schemas**, and **contracts**. Each has a specific job, but together they describe everything about your API.

## API Definition

The API definition lives in `config/apis/` and declares what resources your API exposes:

```ruby
# config/apis/api_v1.rb
Apiwork::API.define '/api/v1' do
  spec :openapi
  spec :typescript
  spec :zod

  resources :posts do
    resources :comments
  end
end
```

This creates RESTful routes for posts and nested comments. Under the hood, Apiwork uses the Rails router — `resources` works exactly as you'd expect.

The `spec` declarations tell Apiwork to generate documentation. Access them at `/.spec/openapi`, `/.spec/typescript`, and `/.spec/zod`.

::: info
The path in `define '/api/v1'` combines with where you mount Apiwork in `routes.rb`. If you mount at `/` and define at `/api/v1`, your routes become `/api/v1/posts`.
:::

## Schema

Schemas define how your data is serialized and what can be queried. They live in `app/schemas/`:

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

      has_many :comments, writable: true
    end
  end
end
```

Each option controls one thing:

| Option | What it does |
|--------|--------------|
| `writable: true` | Field can be set in create/update requests |
| `filterable: true` | Field can be filtered via `?filter[field][op]=value` |
| `sortable: true` | Field can be sorted via `?sort[field]=asc` |

::: tip
You don't need to specify types. Apiwork reads your database columns and infers types, nullability, and defaults automatically.
:::

### Associations

Schemas can include associations:

```ruby
has_many :comments, writable: true
belongs_to :author
has_one :profile, include: :always
```

- `writable: true` — allows nested attributes in create/update
- `include: :always` — always includes the association in responses

## Contract

Contracts validate requests and define response shapes. The simplest contract uses `schema!` to pull everything from the schema:

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

That's it. `schema!` imports:

- **Writable fields** for create/update request bodies
- **Filterable fields** for query parameters
- **Sortable fields** for sort parameters
- **All fields** for response bodies

### Custom Actions

Need an action beyond standard CRUD? Define it explicitly:

```ruby
class PostContract < ApplicationContract
  schema!

  action :publish do
    response do
      body do
        param :post, type: :post
      end
    end
  end
end
```

::: info
You can also write contracts entirely by hand without `schema!`. This gives you full control when you need it — see the Contracts guide for details.
:::

## Controller

Controllers look like regular Rails controllers with two differences:

1. Use `respond` instead of `render`
2. Access validated params via `contract.query` and `contract.body`

- `contract.query` — URL parameters (filters, sorting, pagination)
- `contract.body` — request body (create/update payloads)

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
        post = Post.create!(contract.body[:post])
        respond post, status: :created
      end

      def update
        post = Post.find(params[:id])
        post.update!(contract.body[:post])
        respond post
      end

      def destroy
        post = Post.find(params[:id])
        post.destroy!
        respond post
      end
    end
  end
end
```

::: tip
`contract.query` and `contract.body` replace Strong Parameters. They contain only the fields defined in your schema. Unknown fields are filtered out before your controller runs.
:::

## How They Connect

Here's how everything fits together:

```
┌─────────────────────────────────────────────────────────────┐
│  config/apis/api_v1.rb                                      │
│  API Definition — declares resources and specs              │
└─────────────────────────────┬───────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│  app/contracts/api/v1/post_contract.rb                      │
│  Contract — validates requests, uses schema! for types      │
└─────────────────────────────┬───────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│  app/schemas/api/v1/post_schema.rb                          │
│  Schema — defines attributes, associations, permissions     │
└─────────────────────────────┬───────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│  app/models/post.rb                                         │
│  Model — database columns, validations, associations        │
└─────────────────────────────────────────────────────────────┘
```

**Request flow:**

1. Request arrives at `/api/v1/posts`
2. API definition routes to `PostsController`
3. Contract validates the request using schema types
4. Controller processes the request
5. Schema serializes the response

**The key insight:** Schema is the single source of truth. It knows your data shape, and both contracts (for validation) and serialization (for responses) derive from it.

## Next Steps

Now that you understand the core concepts:

- [Contracts](../core/contracts/introduction.md) — custom validation and manual contracts
- [Schemas](../core/schemas/introduction.md) — associations, computed attributes, and more
- [API Definitions](../core/api-definitions/introduction.md) — key format, metadata, and advanced routing
